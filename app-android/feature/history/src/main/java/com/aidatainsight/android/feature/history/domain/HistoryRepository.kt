package com.aidatainsight.android.feature.history.domain

import com.aidatainsight.android.core.model.history.HistoryRecord

interface HistoryRepository {
    suspend fun loadHistoryPage(): List<HistoryRecord>
    suspend fun deleteHistory(id: String): List<HistoryRecord>
    suspend fun deleteAllHistory(): List<HistoryRecord>
}
