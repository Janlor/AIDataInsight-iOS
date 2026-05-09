package com.aidatainsight.android.feature.aichat.presentation

data class AIChatMessageUiModel(
    val id: String,
    val role: AIChatMessageRoleUi,
    val text: String,
    val isChart: Boolean = false,
)

enum class AIChatMessageRoleUi {
    User,
    Assistant,
}

data class AIChatUiState(
    val templateQuestions: List<String> = emptyList(),
    val messages: List<AIChatMessageUiModel> = emptyList(),
    val input: String = "",
    val historyId: Int? = null,
    val isLoading: Boolean = false,
    val errorMessage: String? = null,
)
