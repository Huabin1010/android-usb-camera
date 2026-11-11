package com.jiangdg.demo.ui.camera

import com.jiangdg.ausbc.camera.bean.CameraRequest
import com.jiangdg.ausbc.render.env.RotateType
import java.util.Locale

enum class SideSection {
    Devices,
    Picture,
    Video,
    Effects,
    Audio,
    Settings,
    About,
}

enum class ImageControl {
    Brightness,
    Contrast,
    Saturation,
    Hue,
    Gain,
    Gamma,
    Sharpness,
    Zoom,
}

enum class CaptureMode {
    Photo,
    Video,
    Audio,
}

enum class Connection {
    Disconnected,
    Opening,
    Opened,
    Failed,
}

data class UsbDeviceItem(
    val deviceId: Int,
    val name: String,
    val vendorId: Int,
    val productId: Int,
)

data class ResolutionOption(
    val width: Int,
    val height: Int,
)

data class CameraUiState(
    val connection: Connection = Connection.Disconnected,
    val errorMessage: String? = null,
    val mode: CaptureMode = CaptureMode.Photo,
    val isRecording: Boolean = false,
    val elapsedSeconds: Int = 0,
    val frameRate: Int = 0,
    val devices: List<UsbDeviceItem> = emptyList(),
    val currentDeviceId: Int? = null,
    val resolutions: List<ResolutionOption> = emptyList(),
    val previewWidth: Int = 640,
    val previewHeight: Int = 480,
    val imageValues: Map<ImageControl, Int> = emptyMap(),
    val imageSupported: Set<ImageControl> = emptySet(),
    val autoFocus: Boolean = false,
    val autoFocusSupported: Boolean = false,
    val autoWhiteBalance: Boolean = false,
    val autoWhiteBalanceSupported: Boolean = false,
    val previewFormat: CameraRequest.PreviewFormat = CameraRequest.PreviewFormat.FORMAT_MJPEG,
    val audioSource: CameraRequest.AudioSource = CameraRequest.AudioSource.SOURCE_SYS_MIC,
    val rotate: RotateType = RotateType.ANGLE_0,
    val segmentMinutes: Int = 0,
    val sidePanel: SideSection? = null,
    val micOn: Boolean = false,
    val filterId: Int = FILTER_NONE,
    val animationId: Int = ANIMATION_NONE,
    val lastMediaPath: String? = null,
    val lastMediaIsVideo: Boolean = false,
    val snackbar: String? = null,
) {
    val controlsEnabled: Boolean
        get() = connection == Connection.Opened

    fun selectMode(mode: CaptureMode): CameraUiState {
        if (isRecording) {
            return this
        }
        return copy(mode = mode)
    }

    fun selectResolution(width: Int, height: Int): CameraUiState {
        if (isRecording || connection != Connection.Opened) {
            return this
        }
        if (previewWidth == width && previewHeight == height) {
            return this
        }
        return copy(previewWidth = width, previewHeight = height)
    }

    fun toggleSide(section: SideSection): CameraUiState {
        return copy(sidePanel = if (sidePanel == section) null else section)
    }

    fun selectPreviewFormat(format: CameraRequest.PreviewFormat): CameraUiState {
        if (isRecording || previewFormat == format) {
            return this
        }
        return copy(previewFormat = format)
    }

    fun selectAudioSource(source: CameraRequest.AudioSource): CameraUiState {
        if (isRecording || audioSource == source) {
            return this
        }
        return copy(audioSource = source)
    }

    fun selectRotate(type: RotateType): CameraUiState {
        if (isRecording || rotate == type) {
            return this
        }
        return copy(rotate = type)
    }

    fun selectSegmentMinutes(minutes: Int): CameraUiState {
        if (isRecording || minutes == segmentMinutes) {
            return this
        }
        return copy(segmentMinutes = minutes.coerceAtLeast(0))
    }
}

object CaptureTimer {
    fun format(totalSeconds: Int): String {
        val safe = totalSeconds.coerceAtLeast(0)
        val hours = safe / 3600
        val minutes = (safe % 3600) / 60
        val seconds = safe % 60
        return if (hours > 0) {
            String.format(Locale.US, "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            String.format(Locale.US, "%02d:%02d", minutes, seconds)
        }
    }
}

const val FILTER_NONE = -1
const val ANIMATION_NONE = -2
