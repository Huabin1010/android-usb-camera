package com.jiangdg.ausbc_flutter

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var permissionResult: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        if (UsbCameraSessionHolder.session == null) {
            val entry = flutterEngine.renderer.createSurfaceTexture()
            val session = UsbCameraSession(this, entry)
            UsbCameraSessionHolder.session = session
            UsbCameraSessionHolder.textureId = entry.id()
            session.publish()
        }
        MethodChannel(messenger, HOST_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "ensurePermissions" -> ensurePermissions(result)
                else -> result.notImplemented()
            }
        }
        MethodChannel(messenger, CAMERA_CHANNEL).setMethodCallHandler { call, result ->
            val session = UsbCameraSessionHolder.session
            if (session == null) {
                result.error("preview", "preview_not_ready", null)
                return@setMethodCallHandler
            }
            session.onMethodCall(call, result)
        }
        EventChannel(messenger, EVENT_CHANNEL).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                UsbCameraSessionHolder.sink = events
                UsbCameraSessionHolder.session?.publish()
            }

            override fun onCancel(arguments: Any?) {
                UsbCameraSessionHolder.sink = null
            }
        })
    }

    override fun onDestroy() {
        UsbCameraSessionHolder.session?.release()
        UsbCameraSessionHolder.session = null
        UsbCameraSessionHolder.textureId = -1L
        UsbCameraSessionHolder.sink = null
        super.onDestroy()
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != PERMISSION_REQUEST) {
            return
        }
        val granted = grantResults.isNotEmpty() && grantResults.all { it == PackageManager.PERMISSION_GRANTED }
        permissionResult?.success(granted)
        permissionResult = null
    }

    private fun ensurePermissions(result: MethodChannel.Result) {
        val missing = requiredPermissions().filter { permission ->
            ContextCompat.checkSelfPermission(this, permission) != PackageManager.PERMISSION_GRANTED
        }
        if (missing.isEmpty()) {
            result.success(true)
            return
        }
        permissionResult = result
        requestPermissions(missing.toTypedArray(), PERMISSION_REQUEST)
    }

    private fun requiredPermissions(): List<String> {
        return buildList {
            add(Manifest.permission.CAMERA)
            add(Manifest.permission.RECORD_AUDIO)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                add(Manifest.permission.READ_MEDIA_IMAGES)
                add(Manifest.permission.READ_MEDIA_VIDEO)
            } else {
                add(Manifest.permission.READ_EXTERNAL_STORAGE)
                if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.P) {
                    add(Manifest.permission.WRITE_EXTERNAL_STORAGE)
                }
            }
        }
    }

    companion object {
        const val HOST_CHANNEL = "com.jiangdg.ausbc/host"
        const val CAMERA_CHANNEL = "com.jiangdg.ausbc/camera"
        const val EVENT_CHANNEL = "com.jiangdg.ausbc/events"
        private const val PERMISSION_REQUEST = 1001
    }
}
