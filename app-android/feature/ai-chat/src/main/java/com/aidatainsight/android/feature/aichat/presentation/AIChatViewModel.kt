package com.aidatainsight.android.feature.aichat.presentation

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.aidatainsight.android.feature.aichat.application.usecase.LoadTemplateUseCase
import com.aidatainsight.android.feature.aichat.data.DefaultAIChatRepository
import com.aidatainsight.android.feature.aichat.domain.AIChatRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class AIChatViewModel(
    repository: AIChatRepository = DefaultAIChatRepository(),
) : ViewModel() {
    private val loadTemplateUseCase = LoadTemplateUseCase(repository)

    private val _uiState = MutableStateFlow(AIChatUiState())
    val uiState: StateFlow<AIChatUiState> = _uiState.asStateFlow()

    init {
        refresh()
    }

    fun refresh() {
        viewModelScope.launch {
            val output = loadTemplateUseCase()
            _uiState.value = AIChatUiState(messages = output.questions)
        }
    }
}
