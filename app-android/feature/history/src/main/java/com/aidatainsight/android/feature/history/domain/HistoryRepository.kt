package com.aidatainsight.android.feature.history.domain

import com.aidatainsight.android.core.model.contract.RecordPage

interface HistoryRepository {
    suspend fun loadHistoryPage(currentPage: Int, pageSize: Int): RecordPage
    suspend fun deleteHistory(historyId: Int)
    suspend fun deleteAllHistory()
}
