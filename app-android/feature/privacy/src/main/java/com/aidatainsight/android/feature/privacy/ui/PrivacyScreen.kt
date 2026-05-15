package com.aidatainsight.android.feature.privacy.ui

import android.annotation.SuppressLint
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.viewinterop.AndroidView
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.aidatainsight.android.core.ui.layout.AIDataInsightGradientBackground
import com.aidatainsight.android.core.ui.theme.AIDataInsightThemeTokens
import com.aidatainsight.android.feature.privacy.presentation.PrivacyPolicyViewModel

@SuppressLint("SetJavaScriptEnabled")
@Composable
fun PrivacyScreen(
    onClose: () -> Unit = {},
    viewModel: PrivacyPolicyViewModel = viewModel(),
) {
    val privacyUrl = remember(viewModel) { viewModel.privacyPolicyUrl() }

    BackHandler(onBack = onClose)

    AIDataInsightGradientBackground(
        modifier = Modifier.fillMaxSize(),
    ) {
        Column(
            modifier = Modifier.fillMaxSize(),
        ) {
            PrivacyNavigationBar(onClose = onClose)
            AndroidView(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f),
                factory = { context ->
                    WebView(context).apply {
                        webViewClient = WebViewClient()
                        settings.javaScriptEnabled = false
                        settings.domStorageEnabled = false
                        setBackgroundColor(android.graphics.Color.TRANSPARENT)
                        loadUrl(privacyUrl)
                    }
                },
                update = { webView ->
                    if (webView.url != privacyUrl) {
                        webView.loadUrl(privacyUrl)
                    }
                },
            )
        }
    }
}

@Composable
private fun PrivacyNavigationBar(onClose: () -> Unit) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .heightIn(min = 48.dp),
    ) {
        IconButton(
            onClick = onClose,
            modifier = Modifier.align(Alignment.CenterStart),
        ) {
            Text(
                text = "‹",
                style = MaterialTheme.typography.headlineMedium,
                color = AIDataInsightThemeTokens.colors.label.primary,
            )
        }
        Text(
            text = "隐私政策",
            modifier = Modifier.align(Alignment.Center),
            style = MaterialTheme.typography.titleLarge,
            fontWeight = FontWeight.SemiBold,
            color = AIDataInsightThemeTokens.colors.label.primary,
        )
    }
}
