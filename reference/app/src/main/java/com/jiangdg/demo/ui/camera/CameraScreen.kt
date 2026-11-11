package com.jiangdg.demo.ui.camera

import android.content.Intent
import android.net.Uri
import android.provider.MediaStore
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.GraphicEq
import androidx.compose.material.icons.filled.PhotoCamera
import androidx.compose.material.icons.filled.PhotoLibrary
import androidx.compose.material.icons.filled.Stop
import androidx.compose.material.icons.filled.Videocam
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilledIconButton
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButtonDefaults
import androidx.compose.material3.LargeFloatingActionButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.SegmentedButton
import androidx.compose.material3.SegmentedButtonDefaults
import androidx.compose.material3.SingleChoiceSegmentedButtonRow
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.invisibleToUser
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.lifecycle.Observer
import androidx.lifecycle.compose.LocalLifecycleOwner
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import coil.compose.AsyncImage
import com.jiangdg.ausbc.camera.CameraSession
import com.jiangdg.ausbc.camera.bean.CameraRequest
import com.jiangdg.ausbc.utils.bus.BusKey
import com.jiangdg.ausbc.utils.bus.EventBus
import com.jiangdg.ausbc.widget.AspectRatioTextureView
import com.jiangdg.demo.R
import java.io.File

@OptIn(ExperimentalMaterial3Api::class, ExperimentalComposeUiApi::class)
@Composable
fun CameraScreen(
    onOpenMulti: () -> Unit,
    viewModel: CameraViewModel = viewModel(),
) {
    val context = LocalContext.current
    val state by viewModel.uiState.collectAsStateWithLifecycle()
    val session = remember(context, viewModel) {
        CameraSession(
            context = context,
            stateCallback = viewModel,
            requestProvider = {
                val current = viewModel.uiState.value
                defaultCameraRequest(current)
            },
        )
    }
    val lifecycleOwner = LocalLifecycleOwner.current
    DisposableEffect(session, lifecycleOwner) {
        viewModel.attach(session)
        val frameRate = EventBus.with<Int>(BusKey.KEY_FRAME_RATE)
        val observer = Observer<Int> { viewModel.onFrameRate(it) }
        frameRate.observe(lifecycleOwner, observer)
        onDispose {
            frameRate.removeObserver(observer)
            viewModel.detach()
            session.release()
        }
    }

    val snackbarHostState = remember { SnackbarHostState() }
    LaunchedEffect(state.snackbar) {
        val message = state.snackbar ?: return@LaunchedEffect
        snackbarHostState.showSnackbar(message)
        viewModel.consumeSnackbar()
    }

    Box(Modifier.fillMaxSize()) {
        AndroidView(
            modifier = Modifier
                .fillMaxSize()
                .semantics { invisibleToUser() },
            factory = { viewContext ->
                AspectRatioTextureView(viewContext).also { preview ->
                    session.bindTextureView(preview)
                    viewModel.onPreviewSurfaceReady()
                }
            },
        )
        Row(
            Modifier
                .fillMaxSize()
                .windowInsetsPadding(WindowInsets.safeDrawing),
        ) {
            SideChrome(
                state = state,
                onToggle = viewModel::toggleSide,
                onDevice = viewModel::selectDevice,
                onResolution = viewModel::selectResolution,
                onFormat = viewModel::selectPreviewFormat,
                onRotate = viewModel::selectRotate,
                onEffect = viewModel::applyEffect,
                onImage = viewModel::setImage,
                onAutoFocus = viewModel::setAutoFocus,
                onAutoWhiteBalance = viewModel::setAutoWhiteBalance,
                onResetImage = viewModel::resetImage,
                onAudioSource = viewModel::selectAudioSource,
                onMic = viewModel::toggleMic,
                onSegment = viewModel::selectSegmentMinutes,
                onMulti = onOpenMulti,
            )
            Box(
                Modifier
                    .weight(1f)
                    .fillMaxHeight()
                    .then(
                        if (state.sidePanel != null) {
                            Modifier.clickable(onClick = viewModel::closeSide)
                        } else {
                            Modifier
                        },
                    ),
            ) {
                StatusCluster(state, Modifier.align(Alignment.TopStart).padding(16.dp))
                if (state.connection != Connection.Opened) {
                    ConnectionMessage(
                        state = state,
                        onRetry = viewModel::retry,
                        modifier = Modifier.align(Alignment.Center),
                    )
                }
                Column(
                    Modifier
                        .align(Alignment.BottomCenter)
                        .fillMaxWidth()
                        .padding(16.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(12.dp),
                ) {
                    ModeRow(
                        mode = state.mode,
                        enabled = state.controlsEnabled && !state.isRecording,
                        onMode = viewModel::selectMode,
                    )
                    Row(
                        horizontalArrangement = Arrangement.spacedBy(24.dp),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        GalleryButton(state.lastMediaPath) {
                            openGallery(context, state.lastMediaPath, state.lastMediaIsVideo)
                        }
                        ShutterButton(state, viewModel::onShutter)
                    }
                }
            }
        }
        SnackbarHost(snackbarHostState, Modifier.align(Alignment.BottomCenter).padding(bottom = 8.dp))
    }
}

@Composable
private fun StatusCluster(state: CameraUiState, modifier: Modifier = Modifier) {
    Column(modifier, verticalArrangement = Arrangement.spacedBy(8.dp)) {
        if (state.frameRate > 0 && state.connection == Connection.Opened) {
            Surface(
                color = MaterialTheme.colorScheme.surfaceContainerHigh,
                shape = MaterialTheme.shapes.small,
            ) {
                Text(
                    text = stringResource(R.string.frame_rate, state.frameRate),
                    modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
                    style = MaterialTheme.typography.labelMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        }
        if (state.isRecording) {
            Surface(
                color = MaterialTheme.colorScheme.surfaceContainerHigh,
                shape = MaterialTheme.shapes.large,
            ) {
                Row(
                    Modifier.padding(horizontal = 12.dp, vertical = 8.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                ) {
                    Box(
                        Modifier
                            .size(12.dp)
                            .clip(CircleShape)
                            .background(MaterialTheme.colorScheme.error),
                    )
                    Text(
                        stringResource(R.string.recording),
                        style = MaterialTheme.typography.titleMedium,
                        color = MaterialTheme.colorScheme.onSurface,
                    )
                    Text(
                        CaptureTimer.format(state.elapsedSeconds),
                        style = MaterialTheme.typography.titleMedium,
                        color = MaterialTheme.colorScheme.onSurface,
                    )
                }
            }
        }
    }
}

@Composable
private fun ConnectionMessage(state: CameraUiState, onRetry: () -> Unit, modifier: Modifier = Modifier) {
    Column(
        modifier.padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        if (state.connection == Connection.Opening) {
            CircularProgressIndicator(color = MaterialTheme.colorScheme.primary)
            return
        }
        Text(
            text = stringResource(
                if (state.connection == Connection.Failed) R.string.camera_failed else R.string.camera_disconnected,
            ),
            style = MaterialTheme.typography.headlineSmall,
            color = MaterialTheme.colorScheme.onSurface,
            textAlign = TextAlign.Center,
        )
        Text(
            text = state.errorMessage ?: stringResource(R.string.camera_disconnected_body),
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center,
        )
        FilledTonalButton(onClick = onRetry) {
            Text(stringResource(R.string.retry))
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun ModeRow(mode: CaptureMode, enabled: Boolean, onMode: (CaptureMode) -> Unit) {
    val modes = CaptureMode.entries
    SingleChoiceSegmentedButtonRow {
        modes.forEachIndexed { index, item ->
            SegmentedButton(
                selected = mode == item,
                onClick = { onMode(item) },
                enabled = enabled,
                shape = SegmentedButtonDefaults.itemShape(index, modes.size),
                icon = { SegmentedButtonDefaults.Icon(active = mode == item) },
            ) {
                Text(stringResource(item.label), style = MaterialTheme.typography.labelLarge)
            }
        }
    }
}

@Composable
private fun ShutterButton(state: CameraUiState, onClick: () -> Unit) {
    val recording = state.isRecording
    val enabled = state.controlsEnabled
    val description = stringResource(if (recording) R.string.cd_stop else R.string.cd_shutter)
    LargeFloatingActionButton(
        onClick = { if (enabled) onClick() },
        containerColor = when {
            !enabled -> MaterialTheme.colorScheme.surfaceContainerHighest
            recording -> MaterialTheme.colorScheme.error
            else -> MaterialTheme.colorScheme.primaryContainer
        },
        contentColor = when {
            !enabled -> MaterialTheme.colorScheme.onSurface
            recording -> MaterialTheme.colorScheme.onError
            else -> MaterialTheme.colorScheme.onPrimaryContainer
        },
        modifier = Modifier.semantics { contentDescription = description },
    ) {
        Icon(
            imageVector = when {
                recording -> Icons.Filled.Stop
                state.mode == CaptureMode.Video -> Icons.Filled.Videocam
                state.mode == CaptureMode.Audio -> Icons.Filled.GraphicEq
                else -> Icons.Filled.PhotoCamera
            },
            contentDescription = null,
            modifier = Modifier.size(36.dp),
        )
    }
}

@Composable
private fun GalleryButton(path: String?, onClick: () -> Unit) {
    val description = stringResource(R.string.cd_gallery)
    FilledIconButton(
        onClick = onClick,
        modifier = Modifier.size(48.dp),
        colors = IconButtonDefaults.filledIconButtonColors(
            containerColor = MaterialTheme.colorScheme.surfaceContainerHighest.copy(alpha = 0.92f),
            contentColor = MaterialTheme.colorScheme.onSurface,
        ),
    ) {
        if (path.isNullOrEmpty()) {
            Icon(Icons.Filled.PhotoLibrary, contentDescription = description)
        } else {
            AsyncImage(
                model = if (path.startsWith("content:")) Uri.parse(path) else File(path),
                contentDescription = description,
                modifier = Modifier
                    .size(32.dp)
                    .clip(MaterialTheme.shapes.small),
                contentScale = ContentScale.Crop,
            )
        }
    }
}

private fun openGallery(context: android.content.Context, path: String?, video: Boolean) {
    val intent = Intent(Intent.ACTION_VIEW).apply {
        if (!path.isNullOrEmpty() && path.startsWith("content:")) {
            setDataAndType(Uri.parse(path), if (video) "video/*" else "image/*")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        } else {
            data = if (video) {
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI
            } else {
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI
            }
        }
    }
    runCatching { context.startActivity(intent) }
}

private fun defaultCameraRequest(state: CameraUiState): CameraRequest {
    return CameraRequest.Builder()
        .setPreviewWidth(state.previewWidth)
        .setPreviewHeight(state.previewHeight)
        .setRenderMode(CameraRequest.RenderMode.OPENGL)
        .setDefaultRotateType(state.rotate)
        .setAudioSource(state.audioSource)
        .setPreviewFormat(state.previewFormat)
        .setAspectRatioShow(true)
        .setCaptureRawImage(false)
        .setRawPreviewData(false)
        .create()
}

private val CaptureMode.label: Int
    get() = when (this) {
        CaptureMode.Photo -> R.string.mode_photo
        CaptureMode.Video -> R.string.mode_video
        CaptureMode.Audio -> R.string.mode_audio
    }
