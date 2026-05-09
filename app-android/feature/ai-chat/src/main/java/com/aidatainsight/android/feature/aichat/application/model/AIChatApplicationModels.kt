package com.aidatainsight.android.feature.aichat.application.model

import com.aidatainsight.android.core.model.contract.AIChatIntentType
import com.aidatainsight.android.core.model.contract.ChartPayload
import com.aidatainsight.android.core.model.contract.ConversationMessage
import com.aidatainsight.android.core.model.contract.FunctionArguments
import com.aidatainsight.android.core.model.contract.FunctionName

sealed interface UseCaseResult<out T> {
    data class Success<T>(val value: T) : UseCaseResult<T>
    data class Failure(val message: String?) : UseCaseResult<Nothing>
}

data class LoadTemplateOutput(
    val questions: List<String>,
)

data class LoadHistoryDetailOutput(
    val messages: List<ConversationMessage>,
)

sealed interface SendFunctionMessageOutput {
    data class Intent(
        val text: String,
        val type: AIChatIntentType,
    ) : SendFunctionMessageOutput

    data class ChartRequest(
        val name: FunctionName,
        val historyId: Int,
        val arguments: FunctionArguments,
    ) : SendFunctionMessageOutput
}

data class LoadChartDataOutput(
    val payload: ChartPayload,
)

