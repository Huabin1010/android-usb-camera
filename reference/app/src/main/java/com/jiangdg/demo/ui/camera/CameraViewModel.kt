package com.jiangdg.demo.ui.camera

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.jiangdg.ausbc.MultiCameraClient
import com.jiangdg.ausbc.callback.ICameraStateCallBack
import com.jiangdg.ausbc.callback.ICaptureCallBack
import com.jiangdg.ausbc.callback.IPlayCallBack
import com.jiangdg.ausbc.camera.CameraSession
import com.jiangdg.ausbc.camera.CameraUVC
import com.jiangdg.ausbc.camera.bean.CameraRequest
import com.jiangdg.ausbc.render.effect.bean.CameraEffect
import com.jiangdg.ausbc.render.env.RotateType
import com.jiangdg.uvc.UVCCamera
import com.jiangdg.utils.MMKVUtils
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch

class CameraViewModel : ViewModel(), ICameraStateCallBack {
    private val _uiState = MutableStateFlow(
        CameraUiState(
            filterId = MMKVUtils.getInt(KEY_FILTER, FILTER_NONE),
            animationId = MMKVUtils.getInt(KEY_ANIMATION, ANIMATION_NONE),
            previewFormat = enumFrom(CameraRequest.PreviewFormat.entries, MMKVUtils.getInt(KEY_FORMAT, 0)),
            audioSource = enumFrom(
                CameraRequest.AudioSource.entries,
                MMKVUtils.getInt(KEY_AUDIO, CameraRequest.AudioSource.SOURCE_SYS_MIC.ordinal),
            ),
            rotate = enumFrom(RotateType.entries, MMKVUtils.getInt(KEY_ROTATE, 0)),
            segmentMinutes = MMKVUtils.getInt(KEY_SEGMENT, 0),
        ),
    )
    val uiState: StateFlow<CameraUiState> = _uiState.asStateFlow()

    var session: CameraSession? = null
        private set

    private var ticker: Job? = null

    fun attach(cameraSession: CameraSession) {
        session = cameraSession
        cameraSession.onDevicesChanged = { refreshDevices() }
        refreshDevices()
    }

    fun detach() {
        session?.onDevicesChanged = null
        session = null
        ticker?.cancel()
    }

    fun onPreviewSurfaceReady() {
        _uiState.update { state ->
            if (state.connection == Connection.Opened) state else state.copy(connection = Connection.Opening)
        }
    }

    fun onFrameRate(fps: Int) {
        _uiState.update { it.copy(frameRate = fps) }
    }

    fun refreshDevices() {
        val devices = session?.getDeviceList().orEmpty().map { device ->
            UsbDeviceItem(
                deviceId = device.deviceId,
                name = device.deviceName ?: device.productName ?: "USB",
                vendorId = device.vendorId,
                productId = device.productId,
            )
        }
        _uiState.update { it.copy(devices = devices) }
    }

    fun refreshResolutions() {
        val sizes = session?.getAllPreviewSizes().orEmpty().map { ResolutionOption(it.width, it.height) }
        _uiState.update { it.copy(resolutions = sizes) }
    }

    fun retry() {
        _uiState.update { it.copy(connection = Connection.Opening, errorMessage = null, snackbar = null) }
        val cameraSession = session ?: return
        val device = cameraSession.getDeviceList()?.firstOrNull()
        if (device == null) {
            cameraSession.register()
            _uiState.update { it.copy(connection = Connection.Disconnected) }
        } else {
            cameraSession.requestPermission(device)
        }
    }

    fun selectDevice(deviceId: Int) {
        val device = session?.getDeviceList()?.firstOrNull { it.deviceId == deviceId } ?: return
        if (device.deviceId == _uiState.value.currentDeviceId && _uiState.value.connection == Connection.Opened) {
            return
        }
        _uiState.update { it.copy(connection = Connection.Opening, currentDeviceId = deviceId) }
        session?.switchCamera(device)
    }

    fun selectMode(mode: CaptureMode) {
        _uiState.update { it.selectMode(mode) }
    }

    fun selectResolution(width: Int, height: Int) {
        val current = _uiState.value
        val next = current.selectResolution(width, height)
        if (next == current) {
            return
        }
        _uiState.value = next
        session?.updateResolution(width, height)
    }

    fun toggleSide(section: SideSection) {
        _uiState.update { it.toggleSide(section) }
    }

    fun closeSide() {
        _uiState.update { it.copy(sidePanel = null) }
    }

    fun selectPreviewFormat(format: CameraRequest.PreviewFormat) {
        applyReopen { it.selectPreviewFormat(format) }
        MMKVUtils.set(KEY_FORMAT, _uiState.value.previewFormat.ordinal)
    }

    fun selectAudioSource(source: CameraRequest.AudioSource) {
        applyReopen { it.selectAudioSource(source) }
        MMKVUtils.set(KEY_AUDIO, _uiState.value.audioSource.ordinal)
    }

    fun selectRotate(type: RotateType) {
        val current = _uiState.value
        val next = current.selectRotate(type)
        if (next == current) {
            return
        }
        _uiState.value = next
        MMKVUtils.set(KEY_ROTATE, type.ordinal)
        session?.peekCamera()?.getCameraRequest()?.defaultRotateType = type
        session?.setRotateType(type)
    }

    fun selectSegmentMinutes(minutes: Int) {
        val current = _uiState.value
        val next = current.selectSegmentMinutes(minutes)
        if (next == current) {
            return
        }
        _uiState.value = next
        MMKVUtils.set(KEY_SEGMENT, next.segmentMinutes)
    }

    fun setImage(control: ImageControl, value: Int) {
        val clamped = value.coerceIn(0, 100)
        when (control) {
            ImageControl.Brightness -> session?.setBrightness(clamped)
            ImageControl.Contrast -> session?.setContrast(clamped)
            ImageControl.Saturation -> session?.setSaturation(clamped)
            ImageControl.Hue -> session?.setHue(clamped)
            ImageControl.Gain -> session?.setGain(clamped)
            ImageControl.Gamma -> session?.setGamma(clamped)
            ImageControl.Sharpness -> session?.setSharpness(clamped)
            ImageControl.Zoom -> session?.setZoom(clamped)
        }
        _uiState.update { it.copy(imageValues = it.imageValues + (control to clamped)) }
    }

    fun setAutoFocus(enabled: Boolean) {
        session?.setAutoFocus(enabled)
        _uiState.update { it.copy(autoFocus = enabled) }
    }

    fun setAutoWhiteBalance(enabled: Boolean) {
        session?.setAutoWhiteBalance(enabled)
        _uiState.update { it.copy(autoWhiteBalance = enabled) }
    }

    fun resetImage() {
        val camera = session ?: return
        camera.resetBrightness()
        camera.resetContrast()
        camera.resetGain()
        camera.resetGamma()
        camera.resetHue()
        camera.resetZoom()
        camera.resetSharpness()
        camera.resetSaturation()
        camera.resetAutoFocus()
        publishImageControls()
    }

    fun toggleMic() {
        val cameraSession = session ?: return
        if (_uiState.value.micOn) {
            cameraSession.stopPlayMic()
            _uiState.update { it.copy(micOn = false) }
            return
        }
        cameraSession.startPlayMic(object : IPlayCallBack {
            override fun onBegin() {
                _uiState.update { it.copy(micOn = true) }
            }

            override fun onError(error: String) {
                _uiState.update { it.copy(micOn = false, snackbar = error) }
            }

            override fun onComplete() {
                _uiState.update { it.copy(micOn = false) }
            }
        })
    }

    fun applyEffect(effect: CameraEffect) {
        session?.updateRenderEffect(effect.classifyId, effect.effect)
        if (effect.classifyId == CameraEffect.CLASSIFY_ID_FILTER) {
            MMKVUtils.set(KEY_FILTER, effect.id)
            _uiState.update { it.copy(filterId = effect.id) }
        } else {
            MMKVUtils.set(KEY_ANIMATION, effect.id)
            _uiState.update { it.copy(animationId = effect.id) }
        }
    }

    fun onShutter() {
        val state = _uiState.value
        val cameraSession = session ?: return
        if (!state.controlsEnabled) {
            return
        }
        when (state.mode) {
            CaptureMode.Photo -> cameraSession.captureImage(captureCallback(timed = false, video = false))
            CaptureMode.Video -> if (state.isRecording) {
                cameraSession.captureVideoStop()
            } else {
                cameraSession.captureVideoStart(
                    captureCallback(timed = true, video = true),
                    durationInSec = state.segmentMinutes * 60L,
                )
            }
            CaptureMode.Audio -> if (state.isRecording) {
                cameraSession.captureAudioStop()
            } else {
                cameraSession.captureAudioStart(captureCallback(timed = true, video = false))
            }
        }
    }

    fun consumeSnackbar() {
        _uiState.update { it.copy(snackbar = null) }
    }

    override fun onCameraState(
        self: MultiCameraClient.ICamera,
        code: ICameraStateCallBack.State,
        msg: String?,
    ) {
        when (code) {
            ICameraStateCallBack.State.OPENED -> {
                val request = self.getCameraRequest()
                _uiState.update { state ->
                    state.copy(
                        connection = Connection.Opened,
                        errorMessage = null,
                        previewWidth = request?.previewWidth ?: state.previewWidth,
                        previewHeight = request?.previewHeight ?: state.previewHeight,
                        currentDeviceId = self.getUsbDevice().deviceId,
                    )
                }
                publishImageControls()
                refreshDevices()
                refreshResolutions()
            }
            ICameraStateCallBack.State.CLOSED -> {
                if (session?.isReconfiguring == true) {
                    return
                }
                stopTicker()
                _uiState.update { it.copy(connection = Connection.Disconnected, isRecording = false, micOn = false) }
            }
            ICameraStateCallBack.State.ERROR -> {
                stopTicker()
                _uiState.update {
                    it.copy(
                        connection = Connection.Failed,
                        errorMessage = msg,
                        snackbar = msg,
                        isRecording = false,
                    )
                }
            }
        }
    }

    private fun captureCallback(timed: Boolean, video: Boolean) = object : ICaptureCallBack {
        override fun onBegin() {
            if (timed) {
                startTicker()
            }
        }

        override fun onError(error: String?) {
            if (timed) {
                stopTicker()
            }
            _uiState.update { it.copy(isRecording = false, snackbar = error ?: "捕获失败") }
        }

        override fun onComplete(path: String?) {
            if (timed) {
                stopTicker()
            }
            _uiState.update {
                it.copy(
                    isRecording = false,
                    lastMediaPath = path ?: it.lastMediaPath,
                    lastMediaIsVideo = if (path == null) it.lastMediaIsVideo else video,
                )
            }
        }
    }

    private fun startTicker() {
        ticker?.cancel()
        _uiState.update { it.copy(isRecording = true, elapsedSeconds = 0) }
        ticker = viewModelScope.launch {
            while (isActive) {
                delay(1_000)
                _uiState.update { it.copy(elapsedSeconds = it.elapsedSeconds + 1) }
            }
        }
    }

    private fun stopTicker() {
        ticker?.cancel()
        ticker = null
        _uiState.update { it.copy(isRecording = false, elapsedSeconds = 0) }
    }

    override fun onCleared() {
        ticker?.cancel()
        super.onCleared()
    }

    private fun applyReopen(transform: (CameraUiState) -> CameraUiState) {
        val current = _uiState.value
        val next = transform(current)
        if (next == current) {
            return
        }
        _uiState.value = next
        if (current.connection == Connection.Opened) {
            _uiState.update { it.copy(connection = Connection.Opening) }
            session?.reopen()
        }
    }

    private fun publishImageControls() {
        val camera = session?.uvcCamera()
        val reported = ImageControl.entries.filter { control ->
            camera?.supports(control.flag) == true
        }.toSet()
        val supported = reported.ifEmpty { ImageControl.entries.toSet() }
        _uiState.update { state ->
            state.copy(
                imageSupported = supported,
                imageValues = supported.associateWith { control ->
                    control.read(camera) ?: state.imageValues[control] ?: 0
                },
                autoFocusSupported = camera?.supports(UVCCamera.CTRL_FOCUS_AUTO) == true || reported.isEmpty(),
                autoWhiteBalanceSupported = camera?.supports(UVCCamera.PU_WB_TEMP_AUTO) == true || reported.isEmpty(),
                autoFocus = camera?.getAutoFocus() == true,
                autoWhiteBalance = camera?.getAutoWhiteBalance() == true,
            )
        }
    }

    companion object {
        const val KEY_FILTER = "filter"
        const val KEY_ANIMATION = "animation"
        const val KEY_FORMAT = "preview_format"
        const val KEY_AUDIO = "audio_source"
        const val KEY_ROTATE = "rotate"
        const val KEY_SEGMENT = "segment_minutes"

        private fun <T> enumFrom(values: List<T>, ordinal: Int): T {
            return values.getOrElse(ordinal) { values.first() }
        }
    }
}

private val ImageControl.flag: Int
    get() = when (this) {
        ImageControl.Brightness -> UVCCamera.PU_BRIGHTNESS
        ImageControl.Contrast -> UVCCamera.PU_CONTRAST
        ImageControl.Saturation -> UVCCamera.PU_SATURATION
        ImageControl.Hue -> UVCCamera.PU_HUE
        ImageControl.Gain -> UVCCamera.PU_GAIN
        ImageControl.Gamma -> UVCCamera.PU_GAMMA
        ImageControl.Sharpness -> UVCCamera.PU_SHARPNESS
        ImageControl.Zoom -> UVCCamera.CTRL_ZOOM_ABS
    }

private fun ImageControl.read(camera: CameraUVC?): Int? {
    return when (this) {
        ImageControl.Brightness -> camera?.getBrightness()
        ImageControl.Contrast -> camera?.getContrast()
        ImageControl.Saturation -> camera?.getSaturation()
        ImageControl.Hue -> camera?.getHue()
        ImageControl.Gain -> camera?.getGain()
        ImageControl.Gamma -> camera?.getGamma()
        ImageControl.Sharpness -> camera?.getSharpness()
        ImageControl.Zoom -> camera?.getZoom()
    }
}
