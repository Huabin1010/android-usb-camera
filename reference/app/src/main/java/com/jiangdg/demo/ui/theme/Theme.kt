package com.jiangdg.demo.ui.theme

import android.os.Build
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext

private val BrandDarkScheme = darkColorScheme(
    primary = Color(0xFFB4C5FF),
    onPrimary = Color(0xFF002A77),
    primaryContainer = Color(0xFF2E5BFF),
    onPrimaryContainer = Color(0xFFE6E8FF),
    secondary = Color(0xFFC4C5D6),
    onSecondary = Color(0xFF2D3042),
    secondaryContainer = Color(0xFF434656),
    onSecondaryContainer = Color(0xFFE0E1F3),
    tertiary = Color(0xFFE6B9C2),
    onTertiary = Color(0xFF452830),
    tertiaryContainer = Color(0xFF5E3D46),
    onTertiaryContainer = Color(0xFFFFD9E1),
    error = Color(0xFFFFB4AB),
    onError = Color(0xFF690005),
    errorContainer = Color(0xFF93000A),
    onErrorContainer = Color(0xFFFFDAD6),
    background = Color(0xFF111318),
    onBackground = Color(0xFFE2E2E9),
    surface = Color(0xFF111318),
    onSurface = Color(0xFFE2E2E9),
    onSurfaceVariant = Color(0xFFC4C5D6),
    surfaceContainerLowest = Color(0xFF0C0E13),
    surfaceContainerLow = Color(0xFF191B20),
    surfaceContainer = Color(0xFF1E2026),
    surfaceContainerHigh = Color(0xFF282A30),
    surfaceContainerHighest = Color(0xFF33353B),
    outline = Color(0xFF8E909F),
    outlineVariant = Color(0xFF444652),
    inverseSurface = Color(0xFFE2E2E9),
    inverseOnSurface = Color(0xFF2F3037),
    inversePrimary = Color(0xFF2E5BFF),
    scrim = Color(0xFF000000),
)

@Composable
fun AusbcTheme(content: @Composable () -> Unit) {
    val context = LocalContext.current
    val colorScheme = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        dynamicDarkColorScheme(context)
    } else {
        BrandDarkScheme
    }
    MaterialTheme(
        colorScheme = colorScheme,
        content = content,
    )
}
