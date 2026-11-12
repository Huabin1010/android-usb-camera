package com.jiangdg.ausbc.camera

import android.content.Context
import android.graphics.SurfaceTexture
import android.hardware.usb.UsbDevice
import android.os.Handler
import android.os.Looper
import android.view.SurfaceHolder
import android.view.SurfaceView
import android.view.TextureView
import com.jiangdg.ausbc.MultiCameraClient
import com.jiangdg.ausbc.callback.ICameraStateCallBack
import com.jiangdg.ausbc.callback.ICaptureCallBack
import com.jiangdg.ausbc.callback.IDeviceConnectCallBack
import com.jiangdg.ausbc.callback.IEncodeDataCallBack
import com.jiangdg.ausbc.callback.IPlayCallBack
import com.jiangdg.ausbc.callback.IPreviewDataCallBack
import com.jiangdg.ausbc.camera.bean.CameraRequest
import com.jiangdg.ausbc.camera.bean.PreviewSize
import com.jiangdg.ausbc.render.effect.AbstractEffect
import com.jiangdg.ausbc.render.env.RotateType
import com.jiangdg.ausbc.utils.Logger
import com.jiangdg.ausbc.utils.SettableFuture
import com.jiangdg.ausbc.widget.IAspectRatio
import com.jiangdg.usb.USBMonitor
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean

/**
 * USB camera session shared by [com.jiangdg.ausbc.base.CameraFragment] and the Compose demo.
 * The preview surface stays a TextureView or SurfaceView; this class only owns the USB lifecycle.
 */
class CameraSession(
    private val context: Context,
    private val stateCallback: ICameraStateCallBack,
    private val requestProvider: () -> CameraRequest,
    private val cameraFactory: (Context, UsbDevice) -> MultiCameraClient.ICamera = { ctx, device ->
        CameraUVC(ctx, device)
    },
    private val defaultDevice: () -> UsbDevice? = { null },
) {
    private val mainHandler = Handler(Looper.getMainLooper())
    private val requestPermission = AtomicBoolean(false)
    private val cameras = hashMapOf<Int, MultiCameraClient.ICamera>()
    private var client: MultiCameraClient? = null
    private var currentCamera: SettableFuture<MultiCameraClient.ICamera>? = null
    private var preview: IAspectRatio? = null
    private var pendingDevice: UsbDevice? = null
    @Volatile
    var isReconfiguring: Boolean = false
        private set

    var onDevicesChanged: (() -> Unit)? = null

    private val stateBridge = object : ICameraStateCallBack {
        override fun onCameraState(
            self: MultiCameraClient.ICamera,
            code: ICameraStateCallBack.State,
            msg: String?,
        ) {
            if (code == ICameraStateCallBack.State.CLOSED) {
                pendingDevice?.let { device ->
                    pendingDevice = null
                    requestPermission(device)
                }
            }
            if (code == ICameraStateCallBack.State.OPENED || code == ICameraStateCallBack.State.ERROR) {
                isReconfiguring = false
            }
            stateCallback.onCameraState(self, code, msg)
        }
    }

    fun bindTextureView(textureView: TextureView) {
        preview = textureView as? IAspectRatio
        textureView.surfaceTextureListener = object : TextureView.SurfaceTextureListener {
            override fun onSurfaceTextureAvailable(surface: SurfaceTexture, width: Int, height: Int) {
                register()
            }

            override fun onSurfaceTextureSizeChanged(surface: SurfaceTexture, width: Int, height: Int) {
                peekCamera()?.setRenderSize(width, height)
            }

            override fun onSurfaceTextureDestroyed(surface: SurfaceTexture): Boolean {
                release()
                return false
            }

            override fun onSurfaceTextureUpdated(surface: SurfaceTexture) = Unit
        }
        if (textureView.isAvailable) {
            register()
        }
    }

    fun bindSurfaceView(surfaceView: SurfaceView) {
        preview = surfaceView as? IAspectRatio
        surfaceView.holder.addCallback(object : SurfaceHolder.Callback {
            override fun surfaceCreated(holder: SurfaceHolder) {
                register()
            }

            override fun surfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
                peekCamera()?.setRenderSize(width, height)
            }

            override fun surfaceDestroyed(holder: SurfaceHolder) {
                release()
            }
        })
    }

    /** Flutter Texture / custom surface — no View lifecycle callbacks. */
    fun bindPreview(aspect: IAspectRatio) {
        preview = aspect
        register()
    }

    fun register() {
        if (client != null) {
            return
        }
        client = MultiCameraClient(context, object : IDeviceConnectCallBack {
            override fun onAttachDev(device: UsbDevice?) {
                device ?: return
                if (cameras.containsKey(device.deviceId)) {
                    return
                }
                cameras[device.deviceId] = cameraFactory(context, device)
                notifyDevices()
                if (requestPermission.get()) {
                    return
                }
                val preferred = defaultDevice()
                if (preferred != null &&
                    (preferred.vendorId != device.vendorId || preferred.productId != device.productId)
                ) {
                    return
                }
                requestPermission(device)
            }

            override fun onDetachDec(device: UsbDevice?) {
                cameras.remove(device?.deviceId)?.setUsbControlBlock(null)
                requestPermission.set(false)
                cancelCurrent()
                notifyDevices()
            }

            override fun onConnectDev(device: UsbDevice?, ctrlBlock: USBMonitor.UsbControlBlock?) {
                device ?: return
                ctrlBlock ?: return
                cameras[device.deviceId]?.apply {
                    setUsbControlBlock(ctrlBlock)
                }?.also { camera ->
                    cancelCurrent()
                    currentCamera = SettableFuture<MultiCameraClient.ICamera>().also { it.set(camera) }
                    openPreview()
                    Logger.i(TAG, "camera connection. pid: ${device.productId}, vid: ${device.vendorId}")
                }
            }

            override fun onDisConnectDec(device: UsbDevice?, ctrlBlock: USBMonitor.UsbControlBlock?) {
                peekCamera()?.closeCamera()
                requestPermission.set(false)
            }

            override fun onCancelDev(device: UsbDevice?) {
                requestPermission.set(false)
                cancelCurrent()
            }
        })
        client?.register()
    }

    fun release() {
        cameras.values.forEach { it.closeCamera() }
        cameras.clear()
        client?.unRegister()
        client?.destroy()
        client = null
        cancelCurrent()
        requestPermission.set(false)
        isReconfiguring = false
        pendingDevice = null
    }

    fun getDeviceList(): MutableList<UsbDevice>? = client?.getDeviceList()

    fun peekCamera(): MultiCameraClient.ICamera? {
        val future = currentCamera ?: return null
        if (!future.isDone) {
            return null
        }
        return try {
            future.get()
        } catch (error: Exception) {
            null
        }
    }

    fun getCurrentCamera(): MultiCameraClient.ICamera? {
        return try {
            currentCamera?.get(2, TimeUnit.SECONDS)
        } catch (error: Exception) {
            error.printStackTrace()
            null
        }
    }

    fun requestPermission(device: UsbDevice?) {
        requestPermission.set(true)
        client?.requestPermission(device)
    }

    fun switchCamera(usbDevice: UsbDevice) {
        val camera = peekCamera()
        if (camera == null || !camera.isCameraOpened()) {
            requestPermission(usbDevice)
            return
        }
        pendingDevice = usbDevice
        isReconfiguring = true
        camera.closeCamera()
    }

    fun updateResolution(width: Int, height: Int) {
        val camera = peekCamera() ?: return
        if (!camera.isCameraOpened() || camera.isRecording()) {
            return
        }
        isReconfiguring = true
        camera.updateResolution(width, height)
    }

    fun reopen() {
        val camera = peekCamera() ?: return
        if (!camera.isCameraOpened() || camera.isRecording()) {
            return
        }
        val next = requestProvider()
        camera.getCameraRequest()?.apply {
            previewWidth = next.previewWidth
            previewHeight = next.previewHeight
            previewFps = next.previewFps
            previewFormat = next.previewFormat
            audioSource = next.audioSource
            defaultRotateType = next.defaultRotateType
        }
        isReconfiguring = true
        camera.reload()
    }

    fun supports(flag: Int): Boolean = uvcCamera()?.supports(flag) == true

    fun captureImage(callBack: ICaptureCallBack, savePath: String? = null) {
        peekCamera()?.captureImage(callBack, savePath)
    }

    fun captureVideoStart(callBack: ICaptureCallBack, path: String? = null, durationInSec: Long = 0L) {
        peekCamera()?.captureVideoStart(callBack, path, durationInSec)
    }

    fun captureVideoStop() {
        peekCamera()?.captureVideoStop()
    }

    fun captureAudioStart(callBack: ICaptureCallBack, path: String? = null) {
        peekCamera()?.captureAudioStart(callBack, path)
    }

    fun captureAudioStop() {
        peekCamera()?.captureAudioStop()
    }

    fun captureStreamStart() = peekCamera()?.captureStreamStart()

    fun captureStreamStop() = peekCamera()?.captureStreamStop()

    fun setEncodeDataCallBack(callBack: IEncodeDataCallBack) {
        peekCamera()?.setEncodeDataCallBack(callBack)
    }

    fun addPreviewDataCallBack(callBack: IPreviewDataCallBack) {
        peekCamera()?.addPreviewDataCallBack(callBack)
    }

    fun removePreviewDataCallBack(callBack: IPreviewDataCallBack) {
        peekCamera()?.removePreviewDataCallBack(callBack)
    }

    fun addRenderEffect(effect: AbstractEffect) = peekCamera()?.addRenderEffect(effect)

    fun removeRenderEffect(effect: AbstractEffect) = peekCamera()?.removeRenderEffect(effect)

    fun updateRenderEffect(classifyId: Int, effect: AbstractEffect?) {
        peekCamera()?.updateRenderEffect(classifyId, effect)
    }

    fun getDefaultEffect() = peekCamera()?.getDefaultEffect()

    fun getAllPreviewSizes(aspectRatio: Double? = null) = peekCamera()?.getAllPreviewSizes(aspectRatio)

    fun getSupportedFrameRates(width: Int, height: Int): List<Int> {
        return (peekCamera() as? CameraUVC)?.getSupportedFrameRates(width, height).orEmpty()
    }

    fun getCurrentPreviewSize(): PreviewSize? {
        return peekCamera()?.getCameraRequest()?.let { PreviewSize(it.previewWidth, it.previewHeight) }
    }

    fun isCameraOpened() = peekCamera()?.isCameraOpened() ?: false

    fun startPlayMic(callBack: IPlayCallBack? = null) = peekCamera()?.startPlayMic(callBack)

    fun stopPlayMic() = peekCamera()?.stopPlayMic()

    fun setRotateType(type: RotateType) = peekCamera()?.setRotateType(type)

    fun openCamera(view: IAspectRatio? = preview) {
        preview = view ?: preview
        openPreview()
    }

    fun closeCamera() {
        peekCamera()?.closeCamera()
    }

    fun uvcCamera(): CameraUVC? = peekCamera() as? CameraUVC

    fun setBrightness(value: Int) = uvcCamera()?.setBrightness(value)

    fun getBrightness(): Int? = uvcCamera()?.getBrightness()

    fun getBrightnessMax(): Int? = uvcCamera()?.getBrightnessMax()

    fun resetBrightness() = uvcCamera()?.resetBrightness()

    fun setAutoFocus(focus: Boolean) = uvcCamera()?.setAutoFocus(focus)

    fun getAutoFocus(): Boolean? = uvcCamera()?.getAutoFocus()

    fun setAutoWhiteBalance(enabled: Boolean) = uvcCamera()?.setAutoWhiteBalance(enabled)

    fun getAutoWhiteBalance(): Boolean? = uvcCamera()?.getAutoWhiteBalance()

    fun resetAutoFocus() = uvcCamera()?.resetAutoFocus()

    fun setContrast(value: Int) = uvcCamera()?.setContrast(value)

    fun getContrast(): Int? = uvcCamera()?.getContrast()

    fun resetContrast() = uvcCamera()?.resetContrast()

    fun setGain(value: Int) = uvcCamera()?.setGain(value)

    fun getGain(): Int? = uvcCamera()?.getGain()

    fun resetGain() = uvcCamera()?.resetGain()

    fun setGamma(value: Int) = uvcCamera()?.setGamma(value)

    fun getGamma(): Int? = uvcCamera()?.getGamma()

    fun resetGamma() = uvcCamera()?.resetGamma()

    fun setHue(value: Int) = uvcCamera()?.setHue(value)

    fun getHue(): Int? = uvcCamera()?.getHue()

    fun resetHue() = uvcCamera()?.resetHue()

    fun setZoom(value: Int) = uvcCamera()?.setZoom(value)

    fun getZoom(): Int? = uvcCamera()?.getZoom()

    fun resetZoom() = uvcCamera()?.resetZoom()

    fun setSharpness(value: Int) = uvcCamera()?.setSharpness(value)

    fun getSharpness(): Int? = uvcCamera()?.getSharpness()

    fun resetSharpness() = uvcCamera()?.resetSharpness()

    fun setSaturation(value: Int) = uvcCamera()?.setSaturation(value)

    fun getSaturation(): Int? = uvcCamera()?.getSaturation()

    fun resetSaturation() = uvcCamera()?.resetSaturation()

    fun sendCameraCommand(command: Int) = uvcCamera()?.sendCameraCommand(command)

    private fun openPreview() {
        val camera = peekCamera() ?: return
        val target = preview
        // Prefer the real preview target (TextureView / SurfaceView / Flutter IAspectRatio).
        camera.openCamera(target, requestProvider())
        camera.setCameraStateCallBack(stateBridge)
        val width = target?.getSurfaceWidth() ?: 0
        val height = target?.getSurfaceHeight() ?: 0
        if (width > 0 && height > 0) {
            // Unblock MultiCameraClient's size future without waiting for View layout.
            mainHandler.post { camera.setRenderSize(width, height) }
        }
    }

    private fun cancelCurrent() {
        try {
            currentCamera?.cancel(true)
        } catch (error: Exception) {
            error.printStackTrace()
        }
        currentCamera = null
    }

    private fun notifyDevices() {
        mainHandler.post { onDevicesChanged?.invoke() }
    }

    companion object {
        private const val TAG = "CameraSession"
    }
}
