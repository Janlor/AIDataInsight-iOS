package com.aidatainsight.android.core.ui.layout

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.BoxWithConstraintsScope
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.safeDrawingPadding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawWithCache
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import com.aidatainsight.android.core.ui.theme.AIDataInsightThemeTokens

@Composable
fun AIDataInsightGradientBackground(
    modifier: Modifier = Modifier,
    respectSafeDrawingArea: Boolean = true,
    avoidIme: Boolean = true,
    content: @Composable BoxWithConstraintsScope.() -> Unit,
) {
    val colors = AIDataInsightThemeTokens.colors

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(colors.groupedBackground.primary)
            .drawWithCache {
                val backgroundBrush = Brush.linearGradient(
                    colorStops = arrayOf(
                        0f to Color(0x142F7BFF),
                        0.3f to Color(0x0518B8FF),
                        0.7f to Color(0x0518B8FF),
                        1f to Color(0x0F2F7BFF),
                    ),
                    start = Offset(size.width * 0.2f, 0f),
                    end = Offset(size.width * 0.8f, size.height),
                )
                onDrawBehind {
                    drawRect(backgroundBrush)
                }
            },
    ) {
        var contentModifier = Modifier.fillMaxSize()
        if (respectSafeDrawingArea) {
            contentModifier = contentModifier.safeDrawingPadding()
        }
        if (avoidIme) {
            contentModifier = contentModifier.imePadding()
        }

        BoxWithConstraints(
            modifier = contentModifier,
            content = content,
        )
    }
}
