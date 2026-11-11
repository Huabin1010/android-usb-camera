package com.jiangdg.demo.ui.camera

import android.content.Context
import android.hardware.usb.UsbDevice
import android.view.TextureView
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.PhotoCamera
import androidx.compose.material.icons.filled.Stop
import androidx.compose.material.icons.filled.Videocam
import androidx.compose.material3.Card
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import com.jiangdg.ausbc.MultiCameraClient
import com.jiangdg.ausbc.callback.ICameraStateCallBack
import com.jiangdg.ausbc.callback.ICaptureCallBack
import com.jiangdg.ausbc.callback.IDeviceConnectCallBack
import com.jiangdg.ausbc.camera.CameraUVC
import com.jiangdg.ausbc.camera.bean.CameraRequest
import com.jiangdg.ausbc.widget.AspectRatioTextureView
import com.jiangdg.demo.R
import com.jiangdg.usb.USBMonitor
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MultiCameraScreen(onBack: () -> Unit) {
    val context = androidx.compose.ui.platform.LocalContext.current
    val host = remember(context) { MultiCameraHost(context) }
    val cameras by host.cameras.collectAsStateWithLifecycleSafe()
    val snackbarHostState = remember { SnackbarHostState() }
    var message by remember { mutableStateOf<String?>(null) }
    DisposableEffect(host) {
        host.start()
        onDispose { host.stop() }
    }
    LaunchedEffect(message) {
        val text = message ?: return@LaunchedEffect
        snackbarHostState.showSnackbar(text)
        message = null
    }
    Scaffold(
        containerColor = MaterialTheme.colorScheme.surface,
        contentWindowInsets = WindowInsets.safeDrawing,
        topBar = {
            TopAppBar(
                title = { Text(stringResource(R.string.menu_multi), style = MaterialTheme.typography.titleLarge) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = stringResource(R.string.cd_back))
                    }
                },
            )
        },
        snackbarHost = { SnackbarHost(snackbarHostState) },
    ) { padding ->
        BoxWithConstraints(Modifier.fillMaxSize().padding(padding)) {
            val columns = when {
                maxWidth >= 840.dp -> 4
                maxWidth >= 600.dp -> 3
                else -> 2
            }
            val margin = if (maxWidth >= 600.dp) 24.dp else 16.dp
            if (cameras.isEmpty()) {
                Column(
                    Modifier.fillMaxSize().padding(margin),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center,
                ) {
                    Text(
                        stringResource(R.string.camera_disconnected),
                        style = MaterialTheme.typography.headlineSmall,
                        textAlign = TextAlign.Center,
                    )
                    Text(
                        stringResource(R.string.camera_disconnected_body),
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        textAlign = TextAlign.Center,
                    )
                }
            } else {
                LazyVerticalGrid(
                    columns = GridCells.Fixed(columns),
                    contentPadding = PaddingValues(margin),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp),
                ) {
                    items(cameras, key = { it.getUsbDevice().deviceId }) { camera ->
                        MultiCameraCard(
                            camera = camera,
                            onSurfaceReady = host::onSurfaceReady,
                            onMessage = { message = it },
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun MultiCameraCard(
    camera: MultiCameraClient.ICamera,
    onSurfaceReady: (MultiCameraClient.ICamera, TextureView) -> Unit,
    onMessage: (String) -> Unit,
) {
    var recording by remember(camera.getUsbDevice().deviceId) { mutableStateOf(false) }
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = MaterialTheme.shapes.medium,
    ) {
        Box {
            AndroidView(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(180.dp),
                factory = { viewContext ->
                    AspectRatioTextureView(viewContext).also { view ->
                        view.surfaceTextureListener = object : TextureView.SurfaceTextureListener {
                            override fun onSurfaceTextureAvailable(
                                surface: android.graphics.SurfaceTexture,
                                width: Int,
                                height: Int,
                            ) {
                                onSurfaceReady(camera, view)
                            }

                            override fun onSurfaceTextureSizeChanged(
                                surface: android.graphics.SurfaceTexture,
                                width: Int,
                                height: Int,
                            ) = Unit

                            override fun onSurfaceTextureDestroyed(surface: android.graphics.SurfaceTexture): Boolean {
                                camera.closeCamera()
                                return false
                            }

                            override fun onSurfaceTextureUpdated(surface: android.graphics.SurfaceTexture) = Unit
                        }
                    }
                },
            )
            Text(
                camera.getUsbDevice().deviceName ?: "",
                modifier = Modifier.align(Alignment.TopStart).padding(8.dp),
                style = MaterialTheme.typography.labelMedium,
                color = MaterialTheme.colorScheme.onSurface,
            )
            androidx.compose.foundation.layout.Row(
                Modifier.align(Alignment.BottomEnd).padding(4.dp),
            ) {
                IconButton(onClick = {
                    camera.captureImage(messageCallback(onMessage))
                }) {
                    Icon(Icons.Filled.PhotoCamera, contentDescription = stringResource(R.string.cd_shutter))
                }
                IconButton(onClick = {
                    if (recording || camera.isRecording()) {
                        camera.captureVideoStop()
                        recording = false
                    } else {
                        recording = true
                        camera.captureVideoStart(object : ICaptureCallBack {
                            override fun onBegin() {
                                recording = true
                            }

                            override fun onError(error: String?) {
                                recording = false
                                onMessage(error ?: "录像失败")
                            }

                            override fun onComplete(path: String?) {
                                recording = false
                                if (!path.isNullOrEmpty()) {
                                    onMessage(path)
                                }
                            }
                        })
                    }
                }) {
                    Icon(
                        if (recording) Icons.Filled.Stop else Icons.Filled.Videocam,
                        contentDescription = stringResource(if (recording) R.string.cd_stop else R.string.mode_video),
                    )
                }
            }
        }
    }
}

private fun messageCallback(onMessage: (String) -> Unit) = object : ICaptureCallBack {
    override fun onBegin() = Unit

    override fun onError(error: String?) {
        onMessage(error ?: "拍照失败")
    }

    override fun onComplete(path: String?) {
        if (!path.isNullOrEmpty()) {
            onMessage(path)
        }
    }
}

@Composable
private fun StateFlow<List<MultiCameraClient.ICamera>>.collectAsStateWithLifecycleSafe() =
    collectAsStateWithLifecycle()

private class MultiCameraHost(context: Context) {
    private val surfaces = hashMapOf<Int, TextureView>()
    private val cameraMap = linkedMapOf<Int, MultiCameraClient.ICamera>()
    private val _cameras = MutableStateFlow<List<MultiCameraClient.ICamera>>(emptyList())
    val cameras: StateFlow<List<MultiCameraClient.ICamera>> = _cameras.asStateFlow()
    private val request = CameraRequest.Builder()
        .setPreviewWidth(640)
        .setPreviewHeight(480)
        .create()
    private val stateCallback = object : ICameraStateCallBack {
        override fun onCameraState(
            self: MultiCameraClient.ICamera,
            code: ICameraStateCallBack.State,
            msg: String?,
        ) = Unit
    }
    private lateinit var client: MultiCameraClient

    init {
        client = MultiCameraClient(context, object : IDeviceConnectCallBack {
        override fun onAttachDev(device: UsbDevice?) {
            device ?: return
            if (cameraMap.containsKey(device.deviceId)) {
                return
            }
            cameraMap[device.deviceId] = CameraUVC(context, device)
            publish()
            client.requestPermission(device)
        }

        override fun onDetachDec(device: UsbDevice?) {
            val removed = cameraMap.remove(device?.deviceId) ?: return
            removed.setUsbControlBlock(null)
            removed.closeCamera()
            surfaces.remove(device?.deviceId)
            publish()
        }

        override fun onConnectDev(device: UsbDevice?, ctrlBlock: USBMonitor.UsbControlBlock?) {
            device ?: return
            ctrlBlock ?: return
            val camera = cameraMap[device.deviceId] ?: return
            camera.setUsbControlBlock(ctrlBlock)
            surfaces[device.deviceId]?.let { view -> open(camera, view) }
            cameraMap.values.firstOrNull { client.hasPermission(it.getUsbDevice()) != true }?.let {
                client.requestPermission(it.getUsbDevice())
            }
            publish()
        }

        override fun onDisConnectDec(device: UsbDevice?, ctrlBlock: USBMonitor.UsbControlBlock?) {
            cameraMap[device?.deviceId]?.closeCamera()
        }

        override fun onCancelDev(device: UsbDevice?) {
            cameraMap[device?.deviceId]?.closeCamera()
        }
    })
    }

    fun start() {
        client.register()
    }

    fun stop() {
        cameraMap.values.forEach { it.closeCamera() }
        cameraMap.clear()
        surfaces.clear()
        client.unRegister()
        client.destroy()
        publish()
    }

    fun onSurfaceReady(camera: MultiCameraClient.ICamera, view: TextureView) {
        val device = camera.getUsbDevice()
        surfaces[device.deviceId] = view
        if (client.hasPermission(device) == true) {
            open(camera, view)
        }
    }

    private fun open(camera: MultiCameraClient.ICamera, view: TextureView) {
        camera.openCamera(view, request)
        camera.setCameraStateCallBack(stateCallback)
    }

    private fun publish() {
        _cameras.value = cameraMap.values.toList()
    }
}
