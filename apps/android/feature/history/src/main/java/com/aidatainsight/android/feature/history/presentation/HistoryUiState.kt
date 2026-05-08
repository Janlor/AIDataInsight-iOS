package com.aidatainsight.android.feature.history.presentation

data class HistoryItemUiModel(
    val id: String,
    val title: String,
)

data class HistorySectionUiModel(
    val title: String,
    val items: List<HistoryItemUiModel>,
)

data class HistoryUiState(
    val sections: List<HistorySectionUiModel> = emptyList(),
)
