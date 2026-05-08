package com.aidatainsight.android.core.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.ReadOnlyComposable
import androidx.compose.runtime.Stable
import androidx.compose.ui.graphics.Color

private val LightColorScheme = lightColorScheme(
    primary = AIDataInsightColors.AccentPrimaryLight,
    onPrimary = Color.White,
    primaryContainer = AIDataInsightColors.AccentSecondaryLight,
    onPrimaryContainer = AIDataInsightColors.LabelPrimaryLight,
    secondary = AIDataInsightColors.AccentPrimaryLight,
    onSecondary = Color.White,
    secondaryContainer = AIDataInsightColors.BackgroundSecondaryLight,
    onSecondaryContainer = AIDataInsightColors.LabelPrimaryLight,
    tertiary = AIDataInsightColors.AccentPrimaryElevated,
    onTertiary = Color.White,
    background = AIDataInsightColors.BackgroundPrimaryLight,
    onBackground = AIDataInsightColors.LabelPrimaryLight,
    surface = AIDataInsightColors.BackgroundPrimaryLight,
    onSurface = AIDataInsightColors.LabelPrimaryLight,
    surfaceVariant = AIDataInsightColors.BackgroundSecondaryLight,
    onSurfaceVariant = AIDataInsightColors.LabelSecondaryLight,
    surfaceTint = AIDataInsightColors.AccentPrimaryLight,
    outline = AIDataInsightColors.SeparatorLight,
    error = AIDataInsightColors.StatusMarkLight,
    onError = Color.White,
)

private val DarkColorScheme = darkColorScheme(
    primary = AIDataInsightColors.AccentPrimaryDark,
    onPrimary = Color.White,
    primaryContainer = AIDataInsightColors.AccentSecondaryDark,
    onPrimaryContainer = AIDataInsightColors.LabelPrimaryDark,
    secondary = AIDataInsightColors.AccentPrimaryDark,
    onSecondary = Color.White,
    secondaryContainer = AIDataInsightColors.BackgroundSecondaryDark,
    onSecondaryContainer = AIDataInsightColors.LabelPrimaryDark,
    tertiary = AIDataInsightColors.AccentPrimaryElevated,
    onTertiary = Color.White,
    background = AIDataInsightColors.BackgroundPrimaryDark,
    onBackground = AIDataInsightColors.LabelPrimaryDark,
    surface = AIDataInsightColors.BackgroundPrimaryDark,
    onSurface = AIDataInsightColors.LabelPrimaryDark,
    surfaceVariant = AIDataInsightColors.BackgroundSecondaryDark,
    onSurfaceVariant = AIDataInsightColors.LabelSecondaryDark,
    surfaceTint = AIDataInsightColors.AccentPrimaryDark,
    outline = AIDataInsightColors.SeparatorDark,
    error = AIDataInsightColors.StatusMarkDark,
    onError = Color.White,
)

@Composable
fun AIDataInsightTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit,
) {
    val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme
    val extendedColors = if (darkTheme) DarkExtendedColors else LightExtendedColors

    CompositionLocalProvider(
        LocalAIDataInsightExtendedColors provides extendedColors,
    ) {
        MaterialTheme(
            colorScheme = colorScheme,
            content = content,
        )
    }
}

@Stable
object AIDataInsightThemeTokens {
    val colors: AIDataInsightExtendedColors
        @Composable
        @ReadOnlyComposable
        get() = LocalAIDataInsightExtendedColors.current
}
