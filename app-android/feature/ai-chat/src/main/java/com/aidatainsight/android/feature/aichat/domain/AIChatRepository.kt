package com.aidatainsight.android.feature.aichat.domain

import com.aidatainsight.android.core.model.aichat.AIChatMessage

interface AIChatRepository {
    suspend fun loadTemplateMessages(): List<AIChatMessage>
    suspend fun loadHistoryMessages(historyId: String): List<AIChatMessage>
    suspend fun sendFunctionMessage(message: String): AIChatMessage
}
