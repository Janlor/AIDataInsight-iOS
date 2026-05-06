package com.aidatainsight.android.feature.history.presentation

import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

class HistoryViewModel : ViewModel() {
    private val _uiState = MutableStateFlow(HistoryUiState(sections = listOf("Today", "This Month", "Other")))
    val uiState: StateFlow<HistoryUiState> = _uiState.asStateFlow()
}
