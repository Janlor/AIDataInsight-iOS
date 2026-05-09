package com.aidatainsight.android.feature.aichat.presentation

import com.aidatainsight.android.core.model.contract.ConversationContentKind
import com.aidatainsight.android.core.model.contract.ConversationMessage
import com.aidatainsight.android.core.model.contract.ConversationRole

object AIChatHistoryMapper {
    fun makeMessages(items: List<ConversationMessage>): List<AIChatMessageUiModel> {
        return items.mapNotNull { item ->
            val text = item.text
                ?: item.chartPayload?.emptyMessage
                ?: item.chartPayload?.series?.joinToString { it.xAxis }
                ?: return@mapNotNull null
            AIChatMessageUiModel(
                id = item.id,
                role = when (item.role) {
                    ConversationRole.User -> AIChatMessageRoleUi.User
                    ConversationRole.Assistant -> AIChatMessageRoleUi.Assistant
                },
                text = text,
                contentKind = when (item.contentKind) {
                    ConversationContentKind.Welcome -> AIChatMessageContentKindUi.Welcome
                    ConversationContentKind.Text -> AIChatMessageContentKindUi.Text
                    ConversationContentKind.Intent -> AIChatMessageContentKindUi.Intent
                    ConversationContentKind.Chart -> AIChatMessageContentKindUi.Chart
                },
                intentType = item.intentType,
                chartPayload = item.chartPayload,
                feedback = item.feedback,
                historyDetailId = item.historyDetailId,
                functionName = item.functionName,
            )
        }
    }
}
