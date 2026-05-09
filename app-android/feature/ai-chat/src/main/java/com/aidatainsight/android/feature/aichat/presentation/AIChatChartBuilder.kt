package com.aidatainsight.android.feature.aichat.presentation

import com.aidatainsight.android.core.model.contract.ConversationMessage

object AIChatChartBuilder {
    fun buildSummary(messages: List<ConversationMessage>): List<String> {
        return messages.map { "${it.role.name}: ${it.text.orEmpty()}" }
    }
}
