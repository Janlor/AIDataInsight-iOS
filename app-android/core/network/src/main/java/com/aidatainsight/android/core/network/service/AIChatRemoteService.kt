package com.aidatainsight.android.core.network.service

import com.aidatainsight.android.core.model.contract.FunctionModel
import com.aidatainsight.android.core.model.contract.AIChatEndpoint
import com.aidatainsight.android.core.model.contract.TemplateQuestionSet
import com.aidatainsight.android.core.network.client.AIDataInsightApiClient
import com.aidatainsight.android.core.network.client.AIDataInsightHttpClientFactory
import kotlinx.coroutines.flow.Flow
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.contentOrNull
import kotlinx.serialization.json.decodeFromJsonElement

interface AIChatRemoteService {
    suspend fun loadChatTemplate(): TemplateQuestionSet?
    suspend fun functionAnalysis(question: String, historyId: Int?): FunctionModel?
    fun streamMessage(question: String): Flow<String>
}

class KtorAIChatRemoteService(
    private val apiClient: AIDataInsightApiClient,
) : AIChatRemoteService {
    override suspend fun loadChatTemplate(): TemplateQuestionSet? {
        val data: JsonElement = apiClient.get(path = "/chat/template") ?: return null
        return when (data) {
            is JsonObject -> AIDataInsightHttpClientFactory.json.decodeFromJsonElement<TemplateQuestionSet>(data)
            is JsonPrimitive -> data.contentOrNull
                ?.takeIf { it.isNotBlank() }
                ?.let { AIDataInsightHttpClientFactory.json.decodeFromString<TemplateQuestionSet>(it) }
            else -> null
        }
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

    override fun streamMessage(question: String): Flow<String> {
        return apiClient.streamServerSentEvents(
            path = AIChatEndpoint.StreamPath,
            query = mapOf("question" to question),
        )
    }
}
