package com.aidatainsight.android.feature.aichat.data

import com.aidatainsight.android.core.account.runtime.AccountRuntime
import com.aidatainsight.android.core.model.contract.FunctionArguments
import com.aidatainsight.android.core.model.contract.FunctionModel
import com.aidatainsight.android.core.model.contract.FunctionName
import com.aidatainsight.android.core.model.contract.HistoryChartDetail
import com.aidatainsight.android.core.model.contract.HistoryRecord
import com.aidatainsight.android.core.model.contract.TemplateQuestionSet
import com.aidatainsight.android.core.network.client.AIDataInsightApiClient
import com.aidatainsight.android.core.network.service.ChartRemoteService
import com.aidatainsight.android.core.network.service.HistoryRemoteService
import com.aidatainsight.android.core.network.service.KtorAIChatRemoteService
import com.aidatainsight.android.core.network.service.KtorChartRemoteService
import com.aidatainsight.android.core.network.service.KtorHistoryRemoteService
import com.aidatainsight.android.feature.aichat.application.AIChatApplicationMapper
import com.aidatainsight.android.feature.aichat.domain.AIChatRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.serialization.json.JsonObject

class DefaultAIChatRepository(
    private val apiClient: AIDataInsightApiClient = AccountRuntime.graph.apiClient,
    private val aiChatRemoteService: KtorAIChatRemoteService = KtorAIChatRemoteService(apiClient),
    private val historyRemoteService: HistoryRemoteService = KtorHistoryRemoteService(apiClient),
    private val chartRemoteService: ChartRemoteService = KtorChartRemoteService(apiClient),
) : AIChatRepository {
    override suspend fun loadTemplate(): TemplateQuestionSet {
        return aiChatRemoteService.loadChatTemplate() ?: TemplateQuestionSet()
    }

    override suspend fun loadHistoryDetail(historyId: Int): HistoryRecord {
        return historyRemoteService.historyDetail(historyId) ?: HistoryRecord(id = historyId)
    }

    override suspend fun sendFunctionMessage(text: String, historyId: Int?): FunctionModel {
        val data = apiClient.get<JsonObject>(
            path = "/chat/function",
            query = mapOf(
                "question" to text,
                "historyId" to historyId,
            ),
        )
        return data?.let(AIChatApplicationMapper::makeFunctionModel)
            ?: FunctionModel(msg = "AI 分析响应为空。")
    }

    override suspend fun loadChartData(
        name: FunctionName,
        historyId: Int,
        arguments: FunctionArguments,
    ): HistoryChartDetail {
        return chartRemoteService.loadChartData(
            functionName = name,
            historyId = historyId,
            arguments = arguments,
        ) ?: HistoryChartDetail(funcType = name)
    }

    override suspend fun sendLikeFeedback(historyDetailId: Int, like: String) {
        historyRemoteService.likeHistoryDetail(
            historyDetailId = historyDetailId,
            like = like,
        )
    }

    override fun streamMessage(text: String): Flow<String> = flow {
        emit(text)
    }
}
