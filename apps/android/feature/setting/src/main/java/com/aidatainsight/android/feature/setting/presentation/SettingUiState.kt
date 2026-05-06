package com.aidatainsight.android.feature.setting.presentation

import com.aidatainsight.android.core.model.setting.SettingSnapshot

data class SettingUiState(
    val snapshot: SettingSnapshot? = null,
    val errorMessage: String? = null,
)
