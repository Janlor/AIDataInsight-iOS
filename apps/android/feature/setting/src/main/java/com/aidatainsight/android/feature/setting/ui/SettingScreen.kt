package com.aidatainsight.android.feature.setting.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.aidatainsight.android.feature.setting.presentation.SettingViewModel

@Composable
fun SettingScreen(
    onOpenPrivacy: () -> Unit,
    onOpenHistory: () -> Unit,
    onOpenAIChat: () -> Unit,
    viewModel: SettingViewModel = viewModel(),
) {
    val uiState by viewModel.uiState.collectAsState()
    val snapshot = uiState.snapshot

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(24.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        Text("Settings", style = MaterialTheme.typography.headlineMedium)
        Text("User: ${snapshot?.accountInfo?.username ?: "-"}")
        Text("Nickname: ${snapshot?.accountInfo?.nickname ?: "-"}")
        Text("Version: ${snapshot?.appVersion ?: "-"}")
        Button(onClick = onOpenPrivacy, modifier = Modifier.fillMaxWidth()) { Text("Privacy") }
        Button(onClick = onOpenHistory, modifier = Modifier.fillMaxWidth()) { Text("History") }
        Button(onClick = onOpenAIChat, modifier = Modifier.fillMaxWidth()) { Text("AI Chat") }
    }
}
