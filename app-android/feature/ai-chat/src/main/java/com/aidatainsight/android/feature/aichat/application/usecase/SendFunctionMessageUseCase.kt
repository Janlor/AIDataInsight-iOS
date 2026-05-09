package com.aidatainsight.android.feature.aichat.application.usecase

import com.aidatainsight.android.feature.aichat.application.AIChatIntentResolver
import com.aidatainsight.android.feature.aichat.application.model.SendFunctionMessageOutput
import com.aidatainsight.android.feature.aichat.application.model.UseCaseResult
import com.aidatainsight.android.feature.aichat.domain.AIChatRepository

class SendFunctionMessageUseCase(
    private val repository: AIChatRepository,
) {
    suspend operator fun invoke(
        text: String,
        historyId: Int?,
    ): UseCaseResult<SendFunctionMessageOutput> {
        val model = repository.sendFunctionMessage(text, historyId)
        val nextHistoryId = model.historyId
            ?: return UseCaseResult.Failure(model.msg)

        val name = model.name
        val arguments = model.arguments
        if (model.hasTool != true || name == null || arguments == null) {
            return UseCaseResult.Failure(model.msg)
        }

        val intentType = AIChatIntentResolver.resolve(arguments)
        if (intentType != null) {
            return UseCaseResult.Success(
                SendFunctionMessageOutput.Intent(text = text, type = intentType),
            )
        }

        return UseCaseResult.Success(
            SendFunctionMessageOutput.ChartRequest(
                name = name,
                historyId = nextHistoryId,
                arguments = arguments,
            ),
        )
    }
}
