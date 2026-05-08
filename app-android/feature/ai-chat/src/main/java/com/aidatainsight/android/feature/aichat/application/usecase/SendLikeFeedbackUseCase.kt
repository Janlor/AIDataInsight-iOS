package com.aidatainsight.android.feature.aichat.application.usecase

class SendLikeFeedbackUseCase {
    suspend operator fun invoke(messageId: String, liked: Boolean): Result<Unit> {
        return Result.success(Unit)
    }
}
