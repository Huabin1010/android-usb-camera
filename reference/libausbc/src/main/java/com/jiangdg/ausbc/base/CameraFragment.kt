package com.jiangdg.ausbc.base

import android.content.Context
import android.hardware.usb.UsbDevice
import android.view.Gravity
import android.view.SurfaceView
import android.view.TextureView
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.RelativeLayout
import com.jiangdg.ausbc.MultiCameraClient
import com.jiangdg.ausbc.callback.ICameraStateCallBack
import com.jiangdg.ausbc.callback.ICaptureCallBack
import com.jiangdg.ausbc.callback.IEncodeDataCallBack
import com.jiangdg.ausbc.callback.IPlayCallBack
import com.jiangdg.ausbc.callback.IPreviewDataCallBack
import com.jiangdg.ausbc.camera.CameraSession
import com.jiangdg.ausbc.camera.CameraUVC
import com.jiangdg.ausbc.camera.bean.CameraRequest
import com.jiangdg.ausbc.camera.bean.PreviewSize
import com.jiangdg.ausbc.render.effect.AbstractEffect
import com.jiangdg.ausbc.render.env.RotateType
import com.jiangdg.ausbc.widget.IAspectRatio

/** One-camera host. USB and preview lifecycle live in [CameraSession]. */
abstract class CameraFragment : BaseFragment(), ICameraStateCallBack {
    private val session: CameraSession by lazy {
        CameraSession(
            context = requireContext(),
            stateCallback = this,
            requestProvider = { getCameraRequest() },
            cameraFactory = { ctx, device -> generateCamera(ctx, device) },
            defaultDevice = { getDefaultCamera() },
        )
    }

    override fun initView() {
        val cameraView = getCameraView()
        when (cameraView) {
            is TextureView -> session.bindTextureView(cameraView)
            is SurfaceView -> session.bindSurfaceView(cameraView)
            else -> session.register()
        }
        if (cameraView is View) {
            getCameraViewContainer()?.apply {
                removeAllViews()
                addView(cameraView, getViewLayoutParams(this))
            }
        }
    }

    override fun clear() {
        session.release()
    }

    protected fun registerMultiCamera() = session.register()

    protected fun unRegisterMultiCamera() = session.release()

    protected fun getDeviceList() = session.getDeviceList()

    protected fun getCurrentCamera(): MultiCameraClient.ICamera? = session.getCurrentCamera()

    protected fun requestPermission(device: UsbDevice?) = session.requestPermission(device)

    protected open fun generateCamera(ctx: Context, device: UsbDevice): MultiCameraClient.ICamera {
        return CameraUVC(ctx, device)
    }

    protected open fun getDefaultCamera(): UsbDevice? = null

    protected fun captureImage(callBack: ICaptureCallBack, savePath: String? = null) {
        session.captureImage(callBack, savePath)
    }

    protected fun getDefaultEffect() = session.getDefaultEffect()

    protected fun switchCamera(usbDevice: UsbDevice) = session.switchCamera(usbDevice)

    protected fun isCameraOpened() = session.isCameraOpened()

    protected fun updateResolution(width: Int, height: Int) = session.updateResolution(width, height)

    protected fun getAllPreviewSizes(aspectRatio: Double? = null) = session.getAllPreviewSizes(aspectRatio)

    protected fun addRenderEffect(effect: AbstractEffect) = session.addRenderEffect(effect)

    protected fun removeRenderEffect(effect: AbstractEffect) = session.removeRenderEffect(effect)

    protected fun updateRenderEffect(classifyId: Int, effect: AbstractEffect?) {
        session.updateRenderEffect(classifyId, effect)
    }

    protected fun captureStreamStart() = session.captureStreamStart()

    protected fun captureStreamStop() = session.captureStreamStop()

    protected fun setEncodeDataCallBack(callBack: IEncodeDataCallBack) {
        session.setEncodeDataCallBack(callBack)
    }

    protected fun addPreviewDataCallBack(callBack: IPreviewDataCallBack) {
        session.addPreviewDataCallBack(callBack)
    }

    fun removePreviewDataCallBack(callBack: IPreviewDataCallBack) {
        session.removePreviewDataCallBack(callBack)
    }

    protected fun captureVideoStart(callBack: ICaptureCallBack, path: String? = null, durationInSec: Long = 0L) {
        session.captureVideoStart(callBack, path, durationInSec)
    }

    protected fun captureVideoStop() = session.captureVideoStop()

    protected fun captureAudioStart(callBack: ICaptureCallBack, path: String? = null) {
        session.captureAudioStart(callBack, path)
    }

    protected fun captureAudioStop() = session.captureAudioStop()

    protected fun startPlayMic(callBack: IPlayCallBack? = null) = session.startPlayMic(callBack)

    protected fun stopPlayMic() = session.stopPlayMic()

    protected fun getCurrentPreviewSize(): PreviewSize? = session.getCurrentPreviewSize()

    protected fun setRotateType(type: RotateType) = session.setRotateType(type)

    protected fun sendCameraCommand(command: Int) = session.sendCameraCommand(command)

    protected fun setAutoFocus(focus: Boolean) = session.setAutoFocus(focus)

    protected fun getAutoFocus(): Boolean? = session.getAutoFocus()

    protected fun resetAutoFocus() = session.resetAutoFocus()

    protected fun setBrightness(brightness: Int) = session.setBrightness(brightness)

    protected fun getBrightness(): Int? = session.getBrightness()

    protected fun resetBrightness() = session.resetBrightness()

    protected fun setContrast(contrast: Int) = session.setContrast(contrast)

    protected fun getContrast(): Int? = session.getContrast()

    protected fun resetContrast() = session.resetContrast()

    protected fun setGain(gain: Int) = session.setGain(gain)

    protected fun getGain(): Int? = session.getGain()

    protected fun resetGain() = session.resetGain()

    protected fun setGamma(gamma: Int) = session.setGamma(gamma)

    protected fun getGamma(): Int? = session.getGamma()

    protected fun resetGamma() = session.resetGamma()

    protected fun setHue(hue: Int) = session.setHue(hue)

    protected fun getHue(): Int? = session.getHue()

    protected fun resetHue() = session.resetHue()

    protected fun setZoom(zoom: Int) = session.setZoom(zoom)

    protected fun getZoom(): Int? = session.getZoom()

    protected fun resetZoom() = session.resetZoom()

    protected fun setSharpness(sharpness: Int) = session.setSharpness(sharpness)

    protected fun getSharpness(): Int? = session.getSharpness()

    protected fun resetSharpness() = session.resetSharpness()

    protected fun setSaturation(saturation: Int) = session.setSaturation(saturation)

    protected fun getSaturation(): Int? = session.getSaturation()

    protected fun resetSaturation() = session.resetSaturation()

    protected fun openCamera(st: IAspectRatio? = null) = session.openCamera(st)

    protected fun closeCamera() = session.closeCamera()

    abstract override fun onCameraState(
        self: MultiCameraClient.ICamera,
        code: ICameraStateCallBack.State,
        msg: String?,
    )

    private fun getViewLayoutParams(viewGroup: ViewGroup): ViewGroup.LayoutParams {
        return when (viewGroup) {
            is FrameLayout -> {
                FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    getGravity(),
                )
            }
            is LinearLayout -> {
                LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.MATCH_PARENT,
                ).apply { gravity = getGravity() }
            }
            is RelativeLayout -> {
                RelativeLayout.LayoutParams(
                    RelativeLayout.LayoutParams.MATCH_PARENT,
                    RelativeLayout.LayoutParams.MATCH_PARENT,
                ).apply {
                    when (getGravity()) {
                        Gravity.TOP -> addRule(RelativeLayout.ALIGN_PARENT_TOP, RelativeLayout.TRUE)
                        Gravity.BOTTOM -> addRule(RelativeLayout.ALIGN_PARENT_BOTTOM, RelativeLayout.TRUE)
                        else -> {
                            addRule(RelativeLayout.CENTER_HORIZONTAL, RelativeLayout.TRUE)
                            addRule(RelativeLayout.CENTER_VERTICAL, RelativeLayout.TRUE)
                        }
                    }
                }
            }
            else -> throw IllegalArgumentException(
                "Unsupported container view, you can use FrameLayout or LinearLayout or RelativeLayout",
            )
        }
    }

    protected abstract fun getCameraView(): IAspectRatio?

    protected abstract fun getCameraViewContainer(): ViewGroup?

    protected open fun getGravity() = Gravity.CENTER

    protected open fun getCameraRequest(): CameraRequest {
        return CameraRequest.Builder()
            .setPreviewWidth(640)
            .setPreviewHeight(480)
            .setRenderMode(CameraRequest.RenderMode.OPENGL)
            .setDefaultRotateType(RotateType.ANGLE_0)
            .setAudioSource(CameraRequest.AudioSource.SOURCE_SYS_MIC)
            .setPreviewFormat(CameraRequest.PreviewFormat.FORMAT_MJPEG)
            .setAspectRatioShow(true)
            .setCaptureRawImage(false)
            .setRawPreviewData(false)
            .create()
    }
}
