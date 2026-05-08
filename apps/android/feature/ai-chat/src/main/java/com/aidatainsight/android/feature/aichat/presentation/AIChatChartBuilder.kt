package com.aidatainsight.android.feature.aichat.presentation

import com.aidatainsight.android.core.model.aichat.AIChatMessage

object AIChatChartBuilder {
    fun buildSummary(messages: List<AIChatMessage>): List<String> {
        return messages.map { "${it.role.name}: ${it.content}" }
    }
}
