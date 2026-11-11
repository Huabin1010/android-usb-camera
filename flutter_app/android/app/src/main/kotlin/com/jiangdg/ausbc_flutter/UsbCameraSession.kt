package com.jiangdg.ausbc_flutter

import android.app.Activity
import android.content.Context
import android.hardware.usb.UsbDevice
import android.os.Handler
import android.os.Looper
import android.view.View
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
import com.jiangdg.ausbc.widget.AspectRatioTextureView
import com.jiangdg.uvc.UVCCamera
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

internal object UsbCameraSessionHolder {
    var session: UsbCameraSession? = null
    var sink: EventChannel.EventSink? = null
}

internal class UsbCameraViewFactory(
    private val activity: Activity,
    codec: io.flutter.plugin.common.MessageCodec<Any>,
) : PlatformViewFactory(codec) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        return UsbCameraPlatformView(activity)
    }
}

internal class UsbCameraPlatformView(
    activity: Activity,
) : PlatformView {
    private val textureView = AspectRatioTextureView(activity)
    private val session = UsbCameraSession(activity, textureView)

    init {
        UsbCameraSessionHolder.session = session
        session.publish()
    }

    override fun getView(): View = textureView

    override fun dispose() {
        if (UsbCameraSessionHolder.session === session) {
            UsbCameraSessionHolder.session = null
        }
        session.release()
    }
}

internal class UsbCameraSession(
    private val activity: Activity,
    textureView: AspectRatioTextureView,
) {
    private val mainHandler = Handler(Looper.getMainLooper())
    private val request = CameraRequest.Builder()
        .setPreviewWidth(640)
        .setPreviewHeight(480)
        .setRenderMode(CameraRequest.RenderMode.OPENGL)
        .setPreviewFormat(CameraRequest.PreviewFormat.FORMAT_MJPEG)
        .setAudioSource(CameraRequest.AudioSource.SOURCE_SYS_MIC)
        .setDefaultRotateType(RotateType.ANGLE_0)
        .create()

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
    private var segmentMinutes = 0
    private var snackbar: String? = null
    private var timer: Runnable? = null

    private val fpsObserver = Observer<Int> { value ->
        frameRate = value ?: 0
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
                toast(error ?: "保存失败")
            }
        }

        override fun onComplete(path: String?) {
            mainHandler.post {
                stopTimer()
                recording = false
                if (!path.isNullOrBlank()) {
                    toast("已保存")
                }
                publish()
            }
        }
    }

    init {
        camera.onDevicesChanged = {
            mainHandler.post {
                refreshDevices()
                publish()
            }
        }
        camera.bindTextureView(textureView)
        EventBus.with<Int>(BusKey.KEY_FRAME_RATE).observeForever(fpsObserver)
    }

    fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "selectDevice" -> selectDevice(call.argument<Int>("id"))
            "selectMode" -> selectMode(call.argument<String>("mode"))
            "shutter" -> shutter()
            "selectResolution" -> selectResolution(call.argument<Int>("width"), call.argument<Int>("height"))
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
        message = msg
        if (code == ICameraStateCallBack.State.OPENED) {
            camera.getCurrentPreviewSize()?.let { size ->
                request.previewWidth = size.width
                request.previewHeight = size.height
            }
            refreshDevices()
        }
        if (!msg.isNullOrBlank() && code == ICameraStateCallBack.State.ERROR) {
            snackbar = msg
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
            "devices" to devices.map { device ->
                mapOf(
                    "id" to device.deviceId,
                    "name" to (device.productName ?: "USB 摄像头"),
                    "summary" to device.deviceName,
                )
            },
            "resolutions" to (camera.getAllPreviewSizes()?.map { size ->
                mapOf("width" to size.width, "height" to size.height)
            } ?: emptyList()),
            "previewWidth" to request.previewWidth,
            "previewHeight" to request.previewHeight,
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
        if (width == null || height == null || recording || !camera.isCameraOpened()) {
            return
        }
        if (width == request.previewWidth && height == request.previewHeight) {
            return
        }
        camera.updateResolution(width, height)
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
        if (camera.isCameraOpened()) {
            camera.reopen()
        }
    }

    private fun selectRotate(name: String?) {
        val next = runCatching { RotateType.valueOf(name ?: return) }.getOrNull() ?: return
        request.defaultRotateType = next
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
        if (camera.isCameraOpened()) {
            camera.reopen()
        }
    }

    private fun selectSegment(minutes: Int?) {
        if (minutes == null || recording) {
            return
        }
        segmentMinutes = minutes
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
            toast("没有发现 USB 摄像头")
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
