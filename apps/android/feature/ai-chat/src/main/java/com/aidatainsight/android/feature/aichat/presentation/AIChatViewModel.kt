package com.aidatainsight.android.feature.aichat.presentation

import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

class AIChatViewModel : ViewModel() {
    private val _uiState = MutableStateFlow(AIChatUiState(messages = listOf("Welcome to AIDataInsight Android")))
    val uiState: StateFlow<AIChatUiState> = _uiState.asStateFlow()
}
