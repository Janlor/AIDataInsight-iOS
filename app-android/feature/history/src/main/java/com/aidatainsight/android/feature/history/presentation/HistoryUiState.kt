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
    val isLoading: Boolean = false,
    val isLoadingMore: Boolean = false,
    val hasMore: Boolean = false,
    val errorMessage: String? = null,
)
