package com.aidatainsight.android.core.ui.theme

import androidx.compose.runtime.Immutable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Color

@Immutable
data class AIDataInsightBackgroundTokens(
    val primary: Color,
    val secondary: Color,
    val tertiary: Color,
    val primaryElevated: Color,
    val secondaryElevated: Color,
    val tertiaryElevated: Color,
)

@Immutable
data class AIDataInsightGroupedBackgroundTokens(
    val primary: Color,
    val secondary: Color,
    val tertiary: Color,
    val primaryElevated: Color,
    val secondaryElevated: Color,
    val tertiaryElevated: Color,
)

@Immutable
data class AIDataInsightLabelTokens(
    val primary: Color,
    val secondary: Color,
    val tertiary: Color,
    val quaternary: Color,
    val quinary: Color,
)

@Immutable
data class AIDataInsightChartTokens(
    val blue: List<Color>,
    val cyan: List<Color>,
    val mint: List<Color>,
    val green: List<Color>,
    val purple: List<Color>,
    val orange: List<Color>,
    val coral: List<Color>,
) {
    val orderedPalettes: List<List<Color>> = listOf(blue, cyan, mint, green, purple, orange, coral)
}

@Immutable
data class AIDataInsightExtendedColors(
    val accentSecondary: Color,
    val accentElevated: Color,
    val separator: Color,
    val statusMark: Color,
    val background: AIDataInsightBackgroundTokens,
    val groupedBackground: AIDataInsightGroupedBackgroundTokens,
    val label: AIDataInsightLabelTokens,
    val chart: AIDataInsightChartTokens,
)

internal val LocalAIDataInsightExtendedColors = staticCompositionLocalOf<AIDataInsightExtendedColors> {
    error("AIDataInsightExtendedColors not provided")
}

internal val LightExtendedColors = AIDataInsightExtendedColors(
    accentSecondary = AIDataInsightColors.AccentSecondaryLight,
    accentElevated = AIDataInsightColors.AccentPrimaryElevated,
    separator = AIDataInsightColors.SeparatorLight,
    statusMark = AIDataInsightColors.StatusMarkLight,
    background = AIDataInsightBackgroundTokens(
        primary = AIDataInsightColors.BackgroundPrimaryLight,
        secondary = AIDataInsightColors.BackgroundSecondaryLight,
        tertiary = AIDataInsightColors.BackgroundTertiaryLight,
        primaryElevated = AIDataInsightColors.BackgroundPrimaryElevatedLight,
        secondaryElevated = AIDataInsightColors.BackgroundSecondaryElevatedLight,
        tertiaryElevated = AIDataInsightColors.BackgroundTertiaryElevatedLight,
    ),
    groupedBackground = AIDataInsightGroupedBackgroundTokens(
        primary = AIDataInsightColors.GroupedBackgroundPrimaryLight,
        secondary = AIDataInsightColors.GroupedBackgroundSecondaryLight,
        tertiary = AIDataInsightColors.GroupedBackgroundTertiaryLight,
        primaryElevated = AIDataInsightColors.GroupedBackgroundPrimaryElevatedLight,
        secondaryElevated = AIDataInsightColors.GroupedBackgroundSecondaryElevatedLight,
        tertiaryElevated = AIDataInsightColors.GroupedBackgroundTertiaryElevatedLight,
    ),
    label = AIDataInsightLabelTokens(
        primary = AIDataInsightColors.LabelPrimaryLight,
        secondary = AIDataInsightColors.LabelSecondaryLight,
        tertiary = AIDataInsightColors.LabelTertiaryLight,
        quaternary = AIDataInsightColors.LabelQuaternaryLight,
        quinary = AIDataInsightColors.LabelQuinaryLight,
    ),
    chart = AIDataInsightChartTokens(
        blue = AIDataInsightColors.ChartBlue,
        cyan = AIDataInsightColors.ChartCyan,
        mint = AIDataInsightColors.ChartMint,
        green = AIDataInsightColors.ChartGreen,
        purple = AIDataInsightColors.ChartPurple,
        orange = AIDataInsightColors.ChartOrange,
        coral = AIDataInsightColors.ChartCoral,
    ),
)

internal val DarkExtendedColors = AIDataInsightExtendedColors(
    accentSecondary = AIDataInsightColors.AccentSecondaryDark,
    accentElevated = AIDataInsightColors.AccentPrimaryElevated,
    separator = AIDataInsightColors.SeparatorDark,
    statusMark = AIDataInsightColors.StatusMarkDark,
    background = AIDataInsightBackgroundTokens(
        primary = AIDataInsightColors.BackgroundPrimaryDark,
        secondary = AIDataInsightColors.BackgroundSecondaryDark,
        tertiary = AIDataInsightColors.BackgroundTertiaryDark,
        primaryElevated = AIDataInsightColors.BackgroundPrimaryElevatedDark,
        secondaryElevated = AIDataInsightColors.BackgroundSecondaryElevatedDark,
        tertiaryElevated = AIDataInsightColors.BackgroundTertiaryElevatedDark,
    ),
    groupedBackground = AIDataInsightGroupedBackgroundTokens(
        primary = AIDataInsightColors.GroupedBackgroundPrimaryDark,
        secondary = AIDataInsightColors.GroupedBackgroundSecondaryDark,
        tertiary = AIDataInsightColors.GroupedBackgroundTertiaryDark,
        primaryElevated = AIDataInsightColors.GroupedBackgroundPrimaryElevatedDark,
        secondaryElevated = AIDataInsightColors.GroupedBackgroundSecondaryElevatedDark,
        tertiaryElevated = AIDataInsightColors.GroupedBackgroundTertiaryElevatedDark,
    ),
    label = AIDataInsightLabelTokens(
        primary = AIDataInsightColors.LabelPrimaryDark,
        secondary = AIDataInsightColors.LabelSecondaryDark,
        tertiary = AIDataInsightColors.LabelTertiaryDark,
        quaternary = AIDataInsightColors.LabelQuaternaryDark,
        quinary = AIDataInsightColors.LabelQuinaryDark,
    ),
    chart = AIDataInsightChartTokens(
        blue = AIDataInsightColors.ChartBlue,
        cyan = AIDataInsightColors.ChartCyan,
        mint = AIDataInsightColors.ChartMint,
        green = AIDataInsightColors.ChartGreen,
        purple = AIDataInsightColors.ChartPurple,
        orange = AIDataInsightColors.ChartOrange,
        coral = AIDataInsightColors.ChartCoral,
    ),
)
