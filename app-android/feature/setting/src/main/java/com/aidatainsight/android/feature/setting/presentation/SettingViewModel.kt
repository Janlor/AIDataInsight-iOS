package com.aidatainsight.android.feature.setting.presentation

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.aidatainsight.android.feature.setting.data.DefaultSettingRepository
import com.aidatainsight.android.feature.setting.domain.SettingRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class SettingViewModel(
    private val repository: SettingRepository = DefaultSettingRepository(),
) : ViewModel() {
    private val _uiState = MutableStateFlow(SettingUiState())
    val uiState: StateFlow<SettingUiState> = _uiState.asStateFlow()

    init {
        refresh()
    }

    fun refresh() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(snapshot = repository.loadSnapshot(), errorMessage = null)
        }
    }
}
