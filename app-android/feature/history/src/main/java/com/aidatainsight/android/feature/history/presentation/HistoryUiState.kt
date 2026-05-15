package com.aidatainsight.android.feature.history.presentation

data class HistoryItemUiModel(
    val id: String,
    val title: String,
    val displayTime: String,
)

data class HistorySectionUiModel(
    val title: String,
    val items: List<HistoryItemUiModel>,
)

data class HistoryUiState(
    val title: String = "历史会话",
    val sections: List<HistorySectionUiModel> = emptyList(),
    val isLoading: Boolean = false,
    val isLoadingMore: Boolean = false,
    val isDeleting: Boolean = false,
    val hasMore: Boolean = false,
    val errorMessage: String? = null,
)
