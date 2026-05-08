package com.aidatainsight.android.core.network.service

import com.aidatainsight.android.core.model.contract.FunctionModel
import com.aidatainsight.android.core.model.contract.TemplateQuestionSet
import com.aidatainsight.android.core.network.client.AIDataInsightApiClient

interface AIChatRemoteService {
    suspend fun loadChatTemplate(): TemplateQuestionSet?
    suspend fun functionAnalysis(question: String, historyId: Int?): FunctionModel?
}

class KtorAIChatRemoteService(
    private val apiClient: AIDataInsightApiClient,
) : AIChatRemoteService {
    override suspend fun loadChatTemplate(): TemplateQuestionSet? {
        return apiClient.get(path = "/chat/template")
    }

    override suspend fun functionAnalysis(question: String, historyId: Int?): FunctionModel? {
        return apiClient.get(
            path = "/chat/function",
            query = mapOf(
                "question" to question,
                "historyId" to historyId,
            ),
        )
    }
}

