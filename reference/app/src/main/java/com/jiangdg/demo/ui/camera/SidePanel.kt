package com.jiangdg.demo.ui.camera

import androidx.compose.foundation.Image
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AspectRatio
import androidx.compose.material.icons.filled.GraphicEq
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.PhotoFilter
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.Tune
import androidx.compose.material.icons.filled.Usb
import androidx.compose.material3.FilledIconButton
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButtonDefaults
import androidx.compose.material3.ListItem
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.RadioButton
import androidx.compose.material3.Slider
import androidx.compose.material3.Surface
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.jiangdg.ausbc.camera.bean.CameraRequest
import com.jiangdg.ausbc.render.effect.EffectBlackWhite
import com.jiangdg.ausbc.render.effect.EffectSoul
import com.jiangdg.ausbc.render.effect.EffectZoom
import com.jiangdg.ausbc.render.effect.bean.CameraEffect
import com.jiangdg.ausbc.render.env.RotateType
import com.jiangdg.demo.R

@Composable
fun SideChrome(
    state: CameraUiState,
    onToggle: (SideSection) -> Unit,
    onDevice: (Int) -> Unit,
    onResolution: (Int, Int) -> Unit,
    onFormat: (CameraRequest.PreviewFormat) -> Unit,
    onRotate: (RotateType) -> Unit,
    onEffect: (CameraEffect) -> Unit,
    onImage: (ImageControl, Int) -> Unit,
    onAutoFocus: (Boolean) -> Unit,
    onAutoWhiteBalance: (Boolean) -> Unit,
    onResetImage: () -> Unit,
    onAudioSource: (CameraRequest.AudioSource) -> Unit,
    onMic: () -> Unit,
    onSegment: (Int) -> Unit,
    onMulti: () -> Unit,
) {
    Row(Modifier.fillMaxHeight()) {
        Rail(selected = state.sidePanel, onToggle = onToggle)
        val section = state.sidePanel
        if (section != null) {
            Surface(
                modifier = Modifier
                    .width(300.dp)
                    .fillMaxHeight(),
                color = MaterialTheme.colorScheme.surfaceContainerHigh,
                shape = RoundedCornerShape(topEnd = 28.dp, bottomEnd = 28.dp),
            ) {
                PanelBody(
                    section = section,
                    state = state,
                    onDevice = onDevice,
                    onResolution = onResolution,
                    onFormat = onFormat,
                    onRotate = onRotate,
                    onEffect = onEffect,
                    onImage = onImage,
                    onAutoFocus = onAutoFocus,
                    onAutoWhiteBalance = onAutoWhiteBalance,
                    onResetImage = onResetImage,
                    onAudioSource = onAudioSource,
                    onMic = onMic,
                    onSegment = onSegment,
                    onMulti = onMulti,
                )
            }
        }
    }
}

@Composable
private fun Rail(selected: SideSection?, onToggle: (SideSection) -> Unit) {
    Surface(
        modifier = Modifier
            .width(72.dp)
            .fillMaxHeight(),
        color = MaterialTheme.colorScheme.surfaceContainer.copy(alpha = 0.94f),
    ) {
        Column(
            modifier = Modifier
                .fillMaxHeight()
                .verticalScroll(rememberScrollState())
                .padding(vertical = 8.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(4.dp),
        ) {
            SideSection.entries.forEach { section ->
                val description = stringResource(section.label)
                val active = selected == section
                FilledIconButton(
                    onClick = { onToggle(section) },
                    modifier = Modifier.size(48.dp),
                    colors = if (active) {
                        IconButtonDefaults.filledIconButtonColors(
                            containerColor = MaterialTheme.colorScheme.secondaryContainer,
                            contentColor = MaterialTheme.colorScheme.onSecondaryContainer,
                        )
                    } else {
                        IconButtonDefaults.filledIconButtonColors(
                            containerColor = MaterialTheme.colorScheme.surfaceContainerHighest,
                            contentColor = MaterialTheme.colorScheme.onSurface,
                        )
                    },
                ) {
                    Icon(section.icon, contentDescription = description, modifier = Modifier.size(24.dp))
                }
            }
        }
    }
}

@Composable
private fun PanelBody(
    section: SideSection,
    state: CameraUiState,
    onDevice: (Int) -> Unit,
    onResolution: (Int, Int) -> Unit,
    onFormat: (CameraRequest.PreviewFormat) -> Unit,
    onRotate: (RotateType) -> Unit,
    onEffect: (CameraEffect) -> Unit,
    onImage: (ImageControl, Int) -> Unit,
    onAutoFocus: (Boolean) -> Unit,
    onAutoWhiteBalance: (Boolean) -> Unit,
    onResetImage: () -> Unit,
    onAudioSource: (CameraRequest.AudioSource) -> Unit,
    onMic: () -> Unit,
    onSegment: (Int) -> Unit,
    onMulti: () -> Unit,
) {
    Column(Modifier.fillMaxSize()) {
        Text(
            stringResource(section.label),
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 16.dp),
            style = MaterialTheme.typography.titleLarge,
        )
        when (section) {
            SideSection.Devices -> DeviceList(state, onDevice)
            SideSection.Picture -> PictureList(state, onImage, onAutoFocus, onAutoWhiteBalance, onResetImage)
            SideSection.Video -> VideoList(state, onResolution, onFormat, onRotate)
            SideSection.Effects -> EffectList(state, onEffect)
            SideSection.Audio -> AudioList(state, onAudioSource, onMic)
            SideSection.Settings -> SettingsList(state, onSegment, onMulti)
            SideSection.About -> AboutList()
        }
    }
}

@Composable
private fun ColumnScope.DeviceList(state: CameraUiState, onDevice: (Int) -> Unit) {
    if (state.devices.isEmpty()) {
        Text(
            stringResource(R.string.camera_disconnected_body),
            modifier = Modifier.padding(horizontal = 16.dp),
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )
        return
    }
    LazyColumn(Modifier.weight(1f, fill = false).fillMaxWidth()) {
        items(state.devices, key = { it.deviceId }) { device ->
            ChoiceRow(
                title = device.name,
                subtitle = stringResource(R.string.device_ids, device.vendorId, device.productId),
                selected = device.deviceId == state.currentDeviceId,
                onClick = { onDevice(device.deviceId) },
            )
        }
    }
}

@Composable
private fun ColumnScope.PictureList(
    state: CameraUiState,
    onImage: (ImageControl, Int) -> Unit,
    onAutoFocus: (Boolean) -> Unit,
    onAutoWhiteBalance: (Boolean) -> Unit,
    onReset: () -> Unit,
) {
    Column(
        Modifier
            .weight(1f, fill = false)
            .verticalScroll(rememberScrollState())
            .padding(bottom = 16.dp),
    ) {
        if (state.autoFocusSupported) {
            SwitchRow(stringResource(R.string.auto_focus), state.autoFocus, state.controlsEnabled, onAutoFocus)
        }
        if (state.autoWhiteBalanceSupported) {
            SwitchRow(
                stringResource(R.string.auto_white_balance),
                state.autoWhiteBalance,
                state.controlsEnabled,
                onAutoWhiteBalance,
            )
        }
        ImageControl.entries.filter { it in state.imageSupported }.forEach { control ->
            val value = state.imageValues[control] ?: 0
            Text(
                stringResource(R.string.control_value, stringResource(control.label), value),
                modifier = Modifier.padding(horizontal = 16.dp, vertical = 4.dp),
                style = MaterialTheme.typography.labelMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            Slider(
                value = value.toFloat(),
                onValueChange = { onImage(control, it.toInt()) },
                enabled = state.controlsEnabled,
                valueRange = 0f..100f,
                modifier = Modifier.padding(horizontal = 16.dp),
            )
        }
        FilledTonalButton(
            onClick = onReset,
            enabled = state.controlsEnabled,
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
        ) {
            Text(stringResource(R.string.reset_image))
        }
    }
}

@Composable
private fun ColumnScope.VideoList(
    state: CameraUiState,
    onResolution: (Int, Int) -> Unit,
    onFormat: (CameraRequest.PreviewFormat) -> Unit,
    onRotate: (RotateType) -> Unit,
) {
    Column(
        Modifier
            .weight(1f, fill = false)
            .verticalScroll(rememberScrollState()),
    ) {
        Text(
            stringResource(R.string.preview_format),
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
            style = MaterialTheme.typography.titleLarge,
        )
        ChoiceRow(stringResource(R.string.format_mjpeg), null, state.previewFormat == CameraRequest.PreviewFormat.FORMAT_MJPEG) {
            onFormat(CameraRequest.PreviewFormat.FORMAT_MJPEG)
        }
        ChoiceRow(stringResource(R.string.format_yuyv), null, state.previewFormat == CameraRequest.PreviewFormat.FORMAT_YUYV) {
            onFormat(CameraRequest.PreviewFormat.FORMAT_YUYV)
        }
        Text(
            stringResource(R.string.rotate_title),
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
            style = MaterialTheme.typography.titleLarge,
        )
        rotateChoices.forEach { (type, label) ->
            ChoiceRow(stringResource(label), null, state.rotate == type) { onRotate(type) }
        }
        Text(
            stringResource(R.string.sheet_resolution),
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
            style = MaterialTheme.typography.titleLarge,
        )
        if (state.resolutions.isEmpty()) {
            Text(
                stringResource(R.string.camera_disconnected_body),
                modifier = Modifier.padding(16.dp),
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
        state.resolutions.forEach { size ->
            ChoiceRow(
                title = "${size.width} × ${size.height}",
                subtitle = stringResource(
                    R.string.aspect_ratio,
                    size.width.toFloat() / size.height.coerceAtLeast(1),
                ),
                selected = size.width == state.previewWidth && size.height == state.previewHeight,
                onClick = { onResolution(size.width, size.height) },
            )
        }
    }
}

@Composable
private fun ColumnScope.EffectList(state: CameraUiState, onEffect: (CameraEffect) -> Unit) {
    val context = LocalContext.current
    var tab by remember { mutableIntStateOf(0) }
    val filters = remember(context) {
        listOf(
            CameraEffect.NONE_FILTER,
            CameraEffect(
                EffectBlackWhite.ID,
                "BlackWhite",
                CameraEffect.CLASSIFY_ID_FILTER,
                effect = EffectBlackWhite(context),
                coverResId = R.mipmap.filter0,
            ),
        )
    }
    val animations = remember(context) {
        listOf(
            CameraEffect.NONE_ANIMATION,
            CameraEffect(
                EffectZoom.ID,
                "Zoom",
                CameraEffect.CLASSIFY_ID_ANIMATION,
                effect = EffectZoom(context),
                coverResId = R.mipmap.filter2,
            ),
            CameraEffect(
                EffectSoul.ID,
                "Soul",
                CameraEffect.CLASSIFY_ID_ANIMATION,
                effect = EffectSoul(context),
                coverResId = R.mipmap.filter1,
            ),
        )
    }
    Row(Modifier.padding(horizontal = 16.dp), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
        FilledTonalButton(onClick = { tab = 0 }) { Text(stringResource(R.string.tab_filter)) }
        FilledTonalButton(onClick = { tab = 1 }) { Text(stringResource(R.string.tab_animation)) }
    }
    val effects = if (tab == 0) filters else animations
    val selectedId = if (tab == 0) state.filterId else state.animationId
    Column(
        Modifier
            .weight(1f, fill = false)
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        effects.forEach { effect ->
            val selected = effect.id == selectedId
            Surface(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable(enabled = state.controlsEnabled) { onEffect(effect) },
                shape = MaterialTheme.shapes.medium,
                color = if (selected) {
                    MaterialTheme.colorScheme.secondaryContainer
                } else {
                    MaterialTheme.colorScheme.surfaceContainerHighest
                },
            ) {
                Row(
                    Modifier.padding(12.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                ) {
                    if (effect.coverResId != null) {
                        Image(
                            painter = painterResource(effect.coverResId!!),
                            contentDescription = null,
                            modifier = Modifier
                                .size(48.dp)
                                .clip(MaterialTheme.shapes.small),
                            contentScale = ContentScale.Crop,
                        )
                    }
                    Text(stringResource(effect.label), style = MaterialTheme.typography.bodyLarge)
                }
            }
        }
    }
}

@Composable
private fun AudioList(
    state: CameraUiState,
    onAudioSource: (CameraRequest.AudioSource) -> Unit,
    onMic: () -> Unit,
) {
    Column(Modifier.verticalScroll(rememberScrollState())) {
        Text(
            stringResource(R.string.audio_source),
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
            style = MaterialTheme.typography.titleLarge,
        )
        ChoiceRow(stringResource(R.string.audio_system), null, state.audioSource == CameraRequest.AudioSource.SOURCE_SYS_MIC) {
            onAudioSource(CameraRequest.AudioSource.SOURCE_SYS_MIC)
        }
        ChoiceRow(stringResource(R.string.audio_device), null, state.audioSource == CameraRequest.AudioSource.SOURCE_DEV_MIC) {
            onAudioSource(CameraRequest.AudioSource.SOURCE_DEV_MIC)
        }
        ChoiceRow(stringResource(R.string.audio_auto), null, state.audioSource == CameraRequest.AudioSource.SOURCE_AUTO) {
            onAudioSource(CameraRequest.AudioSource.SOURCE_AUTO)
        }
        SwitchRow(stringResource(R.string.listen_mic), state.micOn, state.controlsEnabled) { onMic() }
    }
}

@Composable
private fun SettingsList(state: CameraUiState, onSegment: (Int) -> Unit, onMulti: () -> Unit) {
    Column(Modifier.verticalScroll(rememberScrollState())) {
        FilledTonalButton(
            onClick = onMulti,
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
        ) {
            Text(stringResource(R.string.menu_multi))
        }
        Text(
            stringResource(R.string.segment_title),
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
            style = MaterialTheme.typography.titleLarge,
        )
        ChoiceRow(stringResource(R.string.segment_off), null, state.segmentMinutes == 0) { onSegment(0) }
        listOf(1, 5, 10, 30).forEach { minutes ->
            ChoiceRow(
                stringResource(R.string.segment_minutes, minutes),
                null,
                state.segmentMinutes == minutes,
            ) { onSegment(minutes) }
        }
    }
}

@Composable
private fun AboutList() {
    val context = LocalContext.current
    @Suppress("DEPRECATION")
    val version = context.packageManager.getPackageInfo(context.packageName, 0).versionName ?: ""
    Text(
        stringResource(R.string.about_body, version),
        modifier = Modifier.padding(horizontal = 16.dp),
        style = MaterialTheme.typography.bodyMedium,
        color = MaterialTheme.colorScheme.onSurfaceVariant,
    )
}

@Composable
private fun ChoiceRow(title: String, subtitle: String?, selected: Boolean, onClick: () -> Unit) {
    ListItem(
        modifier = Modifier.clickable(onClick = onClick),
        headlineContent = { Text(title, style = MaterialTheme.typography.bodyLarge) },
        supportingContent = subtitle?.let { text ->
            {
                Text(
                    text,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        },
        trailingContent = { RadioButton(selected = selected, onClick = null) },
    )
    HorizontalDivider(color = MaterialTheme.colorScheme.outlineVariant)
}

@Composable
private fun SwitchRow(title: String, checked: Boolean, enabled: Boolean, onChecked: (Boolean) -> Unit) {
    ListItem(
        headlineContent = { Text(title, style = MaterialTheme.typography.bodyLarge) },
        trailingContent = {
            Switch(checked = checked, onCheckedChange = onChecked, enabled = enabled)
        },
    )
}

private val SideSection.label: Int
    get() = when (this) {
        SideSection.Devices -> R.string.side_devices
        SideSection.Picture -> R.string.side_picture
        SideSection.Video -> R.string.side_video
        SideSection.Effects -> R.string.side_effects
        SideSection.Audio -> R.string.side_audio
        SideSection.Settings -> R.string.side_settings
        SideSection.About -> R.string.side_about
    }

private val SideSection.icon: ImageVector
    get() = when (this) {
        SideSection.Devices -> Icons.Filled.Usb
        SideSection.Picture -> Icons.Filled.Tune
        SideSection.Video -> Icons.Filled.AspectRatio
        SideSection.Effects -> Icons.Filled.PhotoFilter
        SideSection.Audio -> Icons.Filled.GraphicEq
        SideSection.Settings -> Icons.Filled.Settings
        SideSection.About -> Icons.Filled.Info
    }

private val ImageControl.label: Int
    get() = when (this) {
        ImageControl.Brightness -> R.string.control_brightness
        ImageControl.Contrast -> R.string.control_contrast
        ImageControl.Saturation -> R.string.control_saturation
        ImageControl.Hue -> R.string.control_hue
        ImageControl.Gain -> R.string.control_gain
        ImageControl.Gamma -> R.string.control_gamma
        ImageControl.Sharpness -> R.string.control_sharpness
        ImageControl.Zoom -> R.string.control_zoom
    }

private val CameraEffect.label: Int
    get() = when (id) {
        EffectBlackWhite.ID -> R.string.effect_black_white
        EffectZoom.ID -> R.string.effect_zoom
        EffectSoul.ID -> R.string.effect_soul
        else -> R.string.effect_none
    }

private val rotateChoices = listOf(
    RotateType.ANGLE_0 to R.string.rotate_0,
    RotateType.ANGLE_90 to R.string.rotate_90,
    RotateType.ANGLE_180 to R.string.rotate_180,
    RotateType.ANGLE_270 to R.string.rotate_270,
    RotateType.FLIP_LEFT_RIGHT to R.string.flip_horizontal,
    RotateType.FLIP_UP_DOWN to R.string.flip_vertical,
)
