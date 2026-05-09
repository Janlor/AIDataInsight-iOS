package com.aidatainsight.android.feature.aichat.presentation

import com.aidatainsight.android.core.model.contract.ConversationMessage

object AIChatHistoryMapper {
    fun makeMessages(items: List<ConversationMessage>): List<String> {
        return items.mapNotNull { item ->
            item.text ?: item.chartPayload?.emptyMessage ?: item.chartPayload?.series?.joinToString { it.xAxis }
        }
    }
}
