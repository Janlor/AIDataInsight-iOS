package com.aidatainsight.android.feature.aichat.presentation

import com.aidatainsight.android.core.model.contract.AIChatIntentType
import com.aidatainsight.android.core.model.contract.ChartPayload
import com.aidatainsight.android.core.model.contract.FeedbackState
import com.aidatainsight.android.core.model.contract.FunctionName

data class AIChatMessageUiModel(
    val id: String,
    val role: AIChatMessageRoleUi,
    val text: String,
    val contentKind: AIChatMessageContentKindUi = AIChatMessageContentKindUi.Text,
    val intentType: AIChatIntentType? = null,
    val chartPayload: ChartPayload? = null,
    val feedback: FeedbackState = FeedbackState.None,
    val historyDetailId: Int? = null,
    val functionName: FunctionName? = null,
    val templateQuestions: List<String> = emptyList(),
    val isStreaming: Boolean = false,
) {
    val isChart: Boolean
        get() = contentKind == AIChatMessageContentKindUi.Chart
}

enum class AIChatMessageRoleUi {
    User,
    Assistant,
}

enum class AIChatMessageContentKindUi {
    Welcome,
    Text,
    Intent,
    Chart,
    Loading,
    Error,
}

data class AIChatUiState(
    val templateQuestions: List<String> = emptyList(),
    val messages: List<AIChatMessageUiModel> = emptyList(),
    val input: String = "",
    val historyId: Int? = null,
    val isLoadingTemplate: Boolean = false,
    val isSending: Boolean = false,
    val isStreaming: Boolean = false,
    val errorMessage: String? = null,
) {
    val inputText: String
        get() = input

    val isLoading: Boolean
        get() = isLoadingTemplate || isSending || isStreaming

    val canSend: Boolean
        get() = input.isNotBlank() && !isLoading

    val canClear: Boolean
        get() = messages.isNotEmpty() || historyId != null || input.isNotBlank()

    val scrollToBottom: Boolean
        get() = messages.isNotEmpty()
}
