package com.aidatainsight.android.feature.aichat.data

import com.aidatainsight.android.core.model.aichat.AIChatMessage
import com.aidatainsight.android.core.model.aichat.AIChatRole
import com.aidatainsight.android.feature.aichat.domain.AIChatRepository

class DefaultAIChatRepository : AIChatRepository {
    override suspend fun loadTemplateMessages(): List<AIChatMessage> {
        return listOf(
            AIChatMessage(
                id = "template-1",
                role = AIChatRole.Assistant,
                content = "Welcome to AIDataInsight Android",
            ),
        )
    }

    override suspend fun loadHistoryMessages(historyId: String): List<AIChatMessage> {
        return listOf(
            AIChatMessage(
                id = "history-$historyId",
                role = AIChatRole.User,
                content = "Replay history $historyId",
            ),
        )
    }

    override suspend fun sendFunctionMessage(message: String): AIChatMessage {
        return AIChatMessage(
            id = "message-${message.hashCode()}",
            role = AIChatRole.Assistant,
            content = "Handled: $message",
        )
    }
}
