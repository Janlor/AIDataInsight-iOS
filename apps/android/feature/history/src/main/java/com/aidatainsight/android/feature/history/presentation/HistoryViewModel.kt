package com.aidatainsight.android.feature.history.presentation

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.aidatainsight.android.feature.history.application.usecase.LoadHistoryPageUseCase
import com.aidatainsight.android.feature.history.data.DefaultHistoryRepository
import com.aidatainsight.android.feature.history.domain.HistoryRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class HistoryViewModel(
    repository: HistoryRepository = DefaultHistoryRepository(),
) : ViewModel() {
    private val loadHistoryPage = LoadHistoryPageUseCase(repository)

    private val _uiState = MutableStateFlow(HistoryUiState())
    val uiState: StateFlow<HistoryUiState> = _uiState.asStateFlow()

    init {
        refresh()
    }

    fun refresh() {
        viewModelScope.launch {
            _uiState.value = HistoryUiState(sections = loadHistoryPage())
        }
    }
}
