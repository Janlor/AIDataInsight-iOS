package com.aidatainsight.android.core.network.service

import com.aidatainsight.android.core.model.contract.HistoryRecord
import com.aidatainsight.android.core.model.contract.RecordPage
import com.aidatainsight.android.core.network.client.AIDataInsightApiClient
import com.aidatainsight.android.core.network.model.LikeHistoryDetailRequest

interface HistoryRemoteService {
    suspend fun pageHistory(currentPage: Int, pageSize: Int): RecordPage?
    suspend fun historyDetail(historyId: Int): HistoryRecord?
    suspend fun likeHistoryDetail(historyDetailId: Int, like: String)
    suspend fun deleteHistory(historyId: Int)
    suspend fun deleteAllHistory()
}

class KtorHistoryRemoteService(
    private val apiClient: AIDataInsightApiClient,
) : HistoryRemoteService {
    override suspend fun pageHistory(currentPage: Int, pageSize: Int): RecordPage? {
        return apiClient.get(
            path = "/history/page",
            query = mapOf(
                "currentPage" to currentPage,
                "pageSize" to pageSize,
            ),
        )
    }

    override suspend fun historyDetail(historyId: Int): HistoryRecord? {
        return apiClient.get(
            path = "/history/detail",
            query = mapOf("historyId" to historyId),
        )
    }

    override suspend fun likeHistoryDetail(historyDetailId: Int, like: String) {
        apiClient.postEmpty(
            path = "/history/like",
            body = LikeHistoryDetailRequest(historyDetailId = historyDetailId, like = like),
        )
    }

    override suspend fun deleteHistory(historyId: Int) {
        apiClient.getEmpty(
            path = "/history/delete",
            query = mapOf("historyId" to historyId),
        )
    }

    override suspend fun deleteAllHistory() {
        apiClient.getEmpty(path = "/history/deleteAll")
    }
}

