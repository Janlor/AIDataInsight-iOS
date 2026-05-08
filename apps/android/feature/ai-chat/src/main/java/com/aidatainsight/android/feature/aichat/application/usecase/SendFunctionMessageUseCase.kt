package com.aidatainsight.android.feature.aichat.application.usecase

import com.aidatainsight.android.feature.aichat.domain.AIChatRepository

class SendFunctionMessageUseCase(
    private val repository: AIChatRepository,
) {
    suspend operator fun invoke(message: String) = repository.sendFunctionMessage(message)
}
