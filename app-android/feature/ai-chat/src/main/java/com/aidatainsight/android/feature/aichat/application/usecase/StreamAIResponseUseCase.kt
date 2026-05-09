package com.aidatainsight.android.feature.aichat.application.usecase

import com.aidatainsight.android.feature.aichat.domain.AIChatRepository
import kotlinx.coroutines.flow.Flow

class StreamAIResponseUseCase(
    private val repository: AIChatRepository,
) {
    operator fun invoke(text: String): Flow<String> = repository.streamMessage(text)
}
