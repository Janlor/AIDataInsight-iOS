package com.aidatainsight.android.feature.aichat.application.usecase

import com.aidatainsight.android.feature.aichat.domain.AIChatRepository

class LoadHistoryDetailUseCase(
    private val repository: AIChatRepository,
) {
    suspend operator fun invoke(historyId: String) = repository.loadHistoryMessages(historyId)
}
