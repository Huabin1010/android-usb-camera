package com.jiangdg.ausbc_flutter

import android.app.Activity
import android.graphics.SurfaceTexture
import android.hardware.usb.UsbDevice
import android.os.Handler
import android.os.Looper
import android.view.Surface
import androidx.lifecycle.Observer
import com.jiangdg.ausbc.callback.ICameraStateCallBack
import com.jiangdg.ausbc.callback.ICaptureCallBack
import com.jiangdg.ausbc.camera.CameraSession
import com.jiangdg.ausbc.camera.bean.CameraRequest
import com.jiangdg.ausbc.render.effect.AbstractEffect
import com.jiangdg.ausbc.render.effect.EffectBlackWhite
import com.jiangdg.ausbc.render.effect.EffectSoul
import com.jiangdg.ausbc.render.effect.EffectZoom
import com.jiangdg.ausbc.render.effect.bean.CameraEffect
import com.jiangdg.ausbc.render.env.RotateType
import com.jiangdg.ausbc.utils.bus.BusKey
import com.jiangdg.ausbc.utils.bus.EventBus
import com.jiangdg.ausbc.widget.IAspectRatio
import com.jiangdg.uvc.UVCCamera
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.TextureRegistry

internal object UsbCameraSessionHolder {
    var session: UsbCameraSession? = null
    var sink: EventChannel.EventSink? = null
    var textureId: Long = -1L
}

/**
 * Bridges AUSBC OpenGL output into a Flutter [Texture] via [TextureRegistry].
 * Avoids PlatformView / TextureView lockHardwareCanvas races that flash the preview.
 */
internal class FlutterPreviewSurface(
    surfaceTexture: SurfaceTexture,
    private var width: Int,
    private var height: Int,
) : IAspectRatio {
    private val surface: Surface

    init {
        surfaceTexture.setDefaultBufferSize(width.coerceAtLeast(1), height.coerceAtLeast(1))
        surface = Surface(surfaceTexture)
    }

    override fun setAspectRatio(width: Int, height: Int) {
        if (width <= 0 || height <= 0) {
            return
        }
        this.width = width
        this.height = height
    }

    fun setBufferSize(width: Int, height: Int, texture: SurfaceTexture) {
        if (width <= 0 || height <= 0) {
            return
        }
        this.width = width
        this.height = height
        texture.setDefaultBufferSize(width, height)
    }

    override fun getSurfaceWidth(): Int = width

    override fun getSurfaceHeight(): Int = height

    override fun getSurface(): Surface = surface

    override fun postUITask(task: () -> Unit) {
        Handler(Looper.getMainLooper()).post(task)
    }

    fun release() {
        surface.release()
    }
}

internal class UsbCameraSession(
    private val activity: Activity,
    private val textureEntry: TextureRegistry.SurfaceTextureEntry,
) {
    private val mainHandler = Handler(Looper.getMainLooper())
    private val prefs = activity.getSharedPreferences(PREFS, Activity.MODE_PRIVATE)
    private val request = CameraRequest.Builder()
        .setPreviewWidth(prefs.getInt(KEY_WIDTH, 640))
        .setPreviewHeight(prefs.getInt(KEY_HEIGHT, 480))
        .setPreviewFps(prefs.getInt(KEY_FPS, 30))
        .setRenderMode(CameraRequest.RenderMode.OPENGL)
        .setPreviewFormat(
            if (prefs.getString(KEY_FORMAT, "mjpeg") == "yuyv") {
                CameraRequest.PreviewFormat.FORMAT_YUYV
            } else {
                CameraRequest.PreviewFormat.FORMAT_MJPEG
            },
        )
        .setAudioSource(
            when (prefs.getString(KEY_AUDIO, "system")) {
                "device" -> CameraRequest.AudioSource.SOURCE_DEV_MIC
                "auto" -> CameraRequest.AudioSource.SOURCE_AUTO
                else -> CameraRequest.AudioSource.SOURCE_SYS_MIC
            },
        )
        .setDefaultRotateType(
            runCatching { RotateType.valueOf(prefs.getString(KEY_ROTATE, RotateType.ANGLE_0.name)!!) }
                .getOrDefault(RotateType.ANGLE_0),
        )
        .create()

    private val previewSurface = FlutterPreviewSurface(
        textureEntry.surfaceTexture(),
        request.previewWidth,
        request.previewHeight,
    )

    private val camera = CameraSession(
        context = activity,
        stateCallback = object : ICameraStateCallBack {
            override fun onCameraState(
                self: com.jiangdg.ausbc.MultiCameraClient.ICamera,
                code: ICameraStateCallBack.State,
                msg: String?,
            ) {
                mainHandler.post { onState(code, msg) }
            }
        },
        requestProvider = { request },
    )

    private var devices: List<UsbDevice> = emptyList()
    private var connection = "closed"
    private var message: String? = null
    private var mode = "photo"
    private var recording = false
    private var elapsedSeconds = 0
    private var frameRate = 0
    private var micOn = false
    private var filterId = -1
    private var animationId = -2
    private var segmentMinutes = prefs.getInt(KEY_SEGMENT, 0)
    private var snackbar: String? = null
    private var timer: Runnable? = null
    private var cachedResolutions: List<Map<String, Int>> = emptyList()
    private var cachedFrameRates: List<Int> = emptyList()
    private var surfaceWidth = request.previewWidth
    private var surfaceHeight = request.previewHeight

    private val fpsObserver = Observer<Int> { value ->
        val next = value ?: 0
        if (next == frameRate) {
            return@Observer
        }
        frameRate = next
        publish()
    }

    private val captureCallback = object : ICaptureCallBack {
        override fun onBegin() {
            mainHandler.post {
                recording = mode != "photo"
                elapsedSeconds = 0
                if (recording) {
                    startTimer()
                }
                publish()
            }
        }

        override fun onError(error: String?) {
            mainHandler.post {
                stopTimer()
                recording = false
                toast(MSG_SAVE_FAILED)
            }
        }

        override fun onComplete(path: String?) {
            mainHandler.post {
                stopTimer()
                recording = false
                if (!path.isNullOrBlank()) {
                    toast(MSG_SAVED)
                }
                publish()
            }
        }
    }

    val textureId: Long get() = textureEntry.id()

    init {
        camera.onDevicesChanged = {
            mainHandler.post {
                refreshDevices()
                refreshSizeCaches()
                publish()
            }
        }
        camera.bindPreview(previewSurface)
        EventBus.with<Int>(BusKey.KEY_FRAME_RATE).observeForever(fpsObserver)
    }

    fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "selectDevice" -> selectDevice(call.argument<Int>("id"))
            "selectMode" -> selectMode(call.argument<String>("mode"))
            "shutter" -> shutter()
            "selectResolution" -> selectResolution(call.argument<Int>("width"), call.argument<Int>("height"))
            "selectFps" -> selectFps(call.argument<Int>("fps"))
            "selectFormat" -> selectFormat(call.argument<String>("format"))
            "selectRotate" -> selectRotate(call.argument<String>("rotate"))
            "selectAudio" -> selectAudio(call.argument<String>("source"))
            "selectSegment" -> selectSegment(call.argument<Int>("minutes"))
            "setImage" -> setImage(call.argument<String>("key"), call.argument<Int>("value"))
            "setAutoFocus" -> camera.setAutoFocus(call.argument<Boolean>("enabled") == true)
            "setAutoWhiteBalance" -> camera.setAutoWhiteBalance(call.argument<Boolean>("enabled") == true)
            "resetImage" -> resetImage()
            "toggleMic" -> toggleMic()
            "applyEffect" -> applyEffect(call.argument<String>("kind"), call.argument<Int>("id"))
            "retry" -> retry()
            "setSurfaceSize" -> setSurfaceSize(call.argument<Int>("width"), call.argument<Int>("height"))
            else -> {
                result.notImplemented()
                return
            }
        }
        publish()
        result.success(null)
    }

    fun publish() {
        val payload = snapshot()
        val sink = UsbCameraSessionHolder.sink ?: return
        if (Looper.myLooper() == Looper.getMainLooper()) {
            sink.success(payload)
        } else {
            mainHandler.post { UsbCameraSessionHolder.sink?.success(payload) }
        }
    }

    fun release() {
        stopTimer()
        EventBus.with<Int>(BusKey.KEY_FRAME_RATE).removeObserver(fpsObserver)
        camera.release()
        previewSurface.release()
        textureEntry.release()
    }

    private fun onState(code: ICameraStateCallBack.State, msg: String?) {
        if (code == ICameraStateCallBack.State.CLOSED && camera.isReconfiguring) {
            return
        }
        connection = when (code) {
            ICameraStateCallBack.State.OPENED -> "opened"
            ICameraStateCallBack.State.ERROR -> "error"
            ICameraStateCallBack.State.CLOSED -> "closed"
        }
        message = when (code) {
            ICameraStateCallBack.State.ERROR -> MSG_CAMERA_ERROR
            ICameraStateCallBack.State.OPENED -> null
            else -> msg
        }
        if (code == ICameraStateCallBack.State.OPENED) {
            camera.getCurrentPreviewSize()?.let { size ->
                request.previewWidth = size.width
                request.previewHeight = size.height
                previewSurface.setAspectRatio(size.width, size.height)
            }
            refreshDevices()
            refreshSizeCaches()
            applySurfaceSize(surfaceWidth, surfaceHeight)
        }
        if (code == ICameraStateCallBack.State.ERROR) {
            snackbar = MSG_CAMERA_ERROR
        }
        publish()
        snackbar = null
    }

    private fun snapshot(): Map<String, Any?> {
        refreshDevices()
        val opened = camera.isCameraOpened()
        val supported = ImageControl.entries.filter { camera.supports(it.flag) }
        val shown = when {
            supported.isNotEmpty() -> supported
            opened -> ImageControl.entries
            else -> emptyList()
        }
        val reportEmpty = opened && supported.isEmpty()
        return mapOf(
            "connection" to connection,
            "deviceId" to camera.peekCamera()?.getUsbDevice()?.deviceId,
            "message" to message,
            "mode" to mode,
            "isRecording" to recording,
            "elapsedSeconds" to elapsedSeconds,
            "frameRate" to frameRate,
            "textureId" to textureId,
            "devices" to devices.map { device ->
                mapOf(
                    "id" to device.deviceId,
                    "name" to (device.productName?.takeIf { it.isNotBlank() } ?: ""),
                    "summary" to device.deviceName,
                )
            },
            "resolutions" to cachedResolutions.ifEmpty {
                refreshSizeCaches()
                cachedResolutions
            },
            "frameRates" to cachedFrameRates.ifEmpty {
                refreshSizeCaches()
                cachedFrameRates
            },
            "previewWidth" to request.previewWidth,
            "previewHeight" to request.previewHeight,
            "previewFps" to request.previewFps,
            "previewFormat" to if (request.previewFormat == CameraRequest.PreviewFormat.FORMAT_YUYV) "yuyv" else "mjpeg",
            "audioSource" to when (request.audioSource) {
                CameraRequest.AudioSource.SOURCE_DEV_MIC -> "device"
                CameraRequest.AudioSource.SOURCE_AUTO -> "auto"
                else -> "system"
            },
            "rotate" to request.defaultRotateType.name,
            "segmentMinutes" to segmentMinutes,
            "imageValues" to shown.associate { control -> control.key to (control.read(camera) ?: 50) },
            "imageSupported" to shown.map { it.key },
            "autoFocus" to (camera.getAutoFocus() ?: false),
            "autoFocusSupported" to (camera.supports(UVCCamera.CTRL_FOCUS_AUTO) || reportEmpty),
            "autoWhiteBalance" to (camera.getAutoWhiteBalance() ?: false),
            "autoWhiteBalanceSupported" to (camera.supports(UVCCamera.PU_WB_TEMP_AUTO) || reportEmpty),
            "micOn" to micOn,
            "filterId" to filterId,
            "animationId" to animationId,
            "snackbar" to snackbar,
        )
    }

    private fun refreshDevices() {
        devices = camera.getDeviceList()?.toList().orEmpty()
    }

    private fun selectDevice(id: Int?) {
        val device = devices.firstOrNull { it.deviceId == id } ?: return
        connection = "closed"
        camera.switchCamera(device)
    }

    private fun selectMode(next: String?) {
        if (next == null || recording || next == mode) {
            return
        }
        if (next == "photo" || next == "video" || next == "audio") {
            mode = next
        }
    }

    private fun shutter() {
        when (mode) {
            "video" -> if (recording) camera.captureVideoStop() else camera.captureVideoStart(captureCallback, durationInSec = segmentMinutes * 60L)
            "audio" -> if (recording) camera.captureAudioStop() else camera.captureAudioStart(captureCallback)
            else -> camera.captureImage(captureCallback)
        }
    }

    private fun selectResolution(width: Int?, height: Int?) {
        if (width == null || height == null || recording) {
            return
        }
        if (width == request.previewWidth && height == request.previewHeight) {
            return
        }
        request.previewWidth = width
        request.previewHeight = height
        previewSurface.setAspectRatio(width, height)
        savePrefs()
        refreshSizeCaches()
        if (camera.isCameraOpened()) {
            camera.updateResolution(width, height)
        }
    }

    private fun selectFps(fps: Int?) {
        if (fps == null || recording || fps < 1) {
            return
        }
        if (fps == request.previewFps) {
            return
        }
        request.previewFps = fps
        savePrefs()
        refreshSizeCaches()
        if (camera.isCameraOpened()) {
            camera.reopen()
        }
    }

    private fun selectFormat(format: String?) {
        val next = when (format) {
            "yuyv" -> CameraRequest.PreviewFormat.FORMAT_YUYV
            "mjpeg" -> CameraRequest.PreviewFormat.FORMAT_MJPEG
            else -> return
        }
        if (recording || next == request.previewFormat) {
            return
        }
        request.previewFormat = next
        savePrefs()
        refreshSizeCaches()
        if (camera.isCameraOpened()) {
            camera.reopen()
        }
    }

    private fun selectRotate(name: String?) {
        val next = runCatching { RotateType.valueOf(name ?: return) }.getOrNull() ?: return
        request.defaultRotateType = next
        savePrefs()
        camera.setRotateType(next)
    }

    private fun selectAudio(source: String?) {
        val next = when (source) {
            "device" -> CameraRequest.AudioSource.SOURCE_DEV_MIC
            "auto" -> CameraRequest.AudioSource.SOURCE_AUTO
            "system" -> CameraRequest.AudioSource.SOURCE_SYS_MIC
            else -> return
        }
        if (recording || next == request.audioSource) {
            return
        }
        request.audioSource = next
        savePrefs()
        if (camera.isCameraOpened()) {
            camera.reopen()
        }
    }

    private fun selectSegment(minutes: Int?) {
        if (minutes == null || recording) {
            return
        }
        segmentMinutes = minutes
        savePrefs()
    }

    private fun setSurfaceSize(width: Int?, height: Int?) {
        if (width == null || height == null) {
            return
        }
        applySurfaceSize(width, height)
    }

    private fun applySurfaceSize(width: Int, height: Int) {
        if (width <= 0 || height <= 0) {
            return
        }
        if (width == surfaceWidth && height == surfaceHeight) {
            previewSurface.setBufferSize(width, height, textureEntry.surfaceTexture())
            return
        }
        surfaceWidth = width
        surfaceHeight = height
        previewSurface.setBufferSize(width, height, textureEntry.surfaceTexture())
        camera.peekCamera()?.setRenderSize(width, height)
    }

    private fun frameRatesFor(width: Int, height: Int): List<Int> {
        val reported = camera.getSupportedFrameRates(width, height)
        if (reported.isNotEmpty()) {
            return reported
        }
        return listOf(15, 24, 30, 60)
    }

    private fun refreshSizeCaches() {
        cachedResolutions = camera.getAllPreviewSizes()?.map { size ->
            mapOf("width" to size.width, "height" to size.height)
        } ?: emptyList()
        cachedFrameRates = frameRatesFor(request.previewWidth, request.previewHeight)
    }

    private fun savePrefs() {
        prefs.edit()
            .putInt(KEY_WIDTH, request.previewWidth)
            .putInt(KEY_HEIGHT, request.previewHeight)
            .putInt(KEY_FPS, request.previewFps)
            .putString(
                KEY_FORMAT,
                if (request.previewFormat == CameraRequest.PreviewFormat.FORMAT_YUYV) "yuyv" else "mjpeg",
            )
            .putString(KEY_ROTATE, request.defaultRotateType.name)
            .putString(
                KEY_AUDIO,
                when (request.audioSource) {
                    CameraRequest.AudioSource.SOURCE_DEV_MIC -> "device"
                    CameraRequest.AudioSource.SOURCE_AUTO -> "auto"
                    else -> "system"
                },
            )
            .putInt(KEY_SEGMENT, segmentMinutes)
            .apply()
    }

    private fun setImage(key: String?, value: Int?) {
        if (key == null || value == null) {
            return
        }
        ImageControl.entries.firstOrNull { it.key == key }?.write(camera, value.coerceIn(0, 100))
    }

    private fun resetImage() {
        ImageControl.entries.forEach { it.reset(camera) }
        camera.resetAutoFocus()
    }

    private fun toggleMic() {
        if (micOn) {
            camera.stopPlayMic()
            micOn = false
        } else {
            camera.startPlayMic(null)
            micOn = true
        }
    }

    private fun applyEffect(kind: String?, id: Int?) {
        if (kind == null || id == null) {
            return
        }
        val effect: AbstractEffect? = when (id) {
            EffectBlackWhite.ID -> EffectBlackWhite(activity)
            EffectSoul.ID -> EffectSoul(activity)
            EffectZoom.ID -> EffectZoom(activity)
            else -> null
        }
        val classify = if (kind == "animation") {
            animationId = id
            CameraEffect.CLASSIFY_ID_ANIMATION
        } else {
            filterId = id
            CameraEffect.CLASSIFY_ID_FILTER
        }
        camera.updateRenderEffect(classify, effect)
    }

    private fun retry() {
        val target = devices.firstOrNull() ?: camera.getDeviceList()?.firstOrNull()
        if (target == null) {
            toast(MSG_NO_DEVICE)
            return
        }
        camera.requestPermission(target)
    }

    private fun toast(text: String) {
        snackbar = text
        publish()
        snackbar = null
    }

    private fun startTimer() {
        stopTimer()
        val tick = object : Runnable {
            override fun run() {
                if (!recording) {
                    return
                }
                elapsedSeconds += 1
                publish()
                mainHandler.postDelayed(this, 1000)
            }
        }
        timer = tick
        mainHandler.postDelayed(tick, 1000)
    }

    private fun stopTimer() {
        timer?.let { mainHandler.removeCallbacks(it) }
        timer = null
        elapsedSeconds = 0
    }

    companion object {
        private const val PREFS = "ausbc_prefs"
        private const val KEY_WIDTH = "preview_width"
        private const val KEY_HEIGHT = "preview_height"
        private const val KEY_FPS = "preview_fps"
        private const val KEY_FORMAT = "preview_format"
        private const val KEY_ROTATE = "rotate"
        private const val KEY_AUDIO = "audio_source"
        private const val KEY_SEGMENT = "segment_minutes"

        private const val MSG_SAVED = "saved"
        private const val MSG_SAVE_FAILED = "save_failed"
        private const val MSG_NO_DEVICE = "no_device"
        private const val MSG_CAMERA_ERROR = "camera_error"
    }
}

private enum class ImageControl(
    val key: String,
    val flag: Int,
    val read: (CameraSession) -> Int?,
    val write: (CameraSession, Int) -> Unit,
    val reset: (CameraSession) -> Unit,
) {
    BRIGHTNESS("brightness", UVCCamera.PU_BRIGHTNESS, { it.getBrightness() }, { session, value -> session.setBrightness(value) }, { it.resetBrightness() }),
    CONTRAST("contrast", UVCCamera.PU_CONTRAST, { it.getContrast() }, { session, value -> session.setContrast(value) }, { it.resetContrast() }),
    SATURATION("saturation", UVCCamera.PU_SATURATION, { it.getSaturation() }, { session, value -> session.setSaturation(value) }, { it.resetSaturation() }),
    HUE("hue", UVCCamera.PU_HUE, { it.getHue() }, { session, value -> session.setHue(value) }, { it.resetHue() }),
    GAIN("gain", UVCCamera.PU_GAIN, { it.getGain() }, { session, value -> session.setGain(value) }, { it.resetGain() }),
    GAMMA("gamma", UVCCamera.PU_GAMMA, { it.getGamma() }, { session, value -> session.setGamma(value) }, { it.resetGamma() }),
    SHARPNESS("sharpness", UVCCamera.PU_SHARPNESS, { it.getSharpness() }, { session, value -> session.setSharpness(value) }, { it.resetSharpness() }),
    ZOOM("zoom", UVCCamera.CTRL_ZOOM_ABS, { it.getZoom() }, { session, value -> session.setZoom(value) }, { it.resetZoom() }),
}
