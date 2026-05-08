package com.aidatainsight.android.feature.aichat.application.usecase

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow

class StreamAIResponseUseCase {
    operator fun invoke(prompt: String): Flow<String> = flow {
        emit("Streaming scaffold for: $prompt")
    }
}
