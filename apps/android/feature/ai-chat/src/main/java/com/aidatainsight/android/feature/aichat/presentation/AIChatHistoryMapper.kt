package com.aidatainsight.android.feature.aichat.presentation

import com.aidatainsight.android.core.model.aichat.AIChatMessage

object AIChatHistoryMapper {
    fun makeMessages(items: List<AIChatMessage>): List<String> {
        return items.map { it.content }
    }
}
