package com.aidatainsight.android.feature.aichat.application.usecase

import com.aidatainsight.android.feature.aichat.domain.AIChatRepository

class LoadTemplateUseCase(
    private val repository: AIChatRepository,
) {
    suspend operator fun invoke() = repository.loadTemplateMessages()
}
