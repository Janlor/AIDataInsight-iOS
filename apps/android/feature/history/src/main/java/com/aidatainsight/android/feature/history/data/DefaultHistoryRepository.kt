package com.aidatainsight.android.feature.history.data

import com.aidatainsight.android.core.model.history.HistoryRecord
import com.aidatainsight.android.feature.history.domain.HistoryRepository

class DefaultHistoryRepository : HistoryRepository {
    private val seedRecords = listOf(
        HistoryRecord(id = "today-1", title = "Today revenue summary", createdAtLabel = "Today"),
        HistoryRecord(id = "month-1", title = "Monthly sales comparison", createdAtLabel = "This Month"),
        HistoryRecord(id = "other-1", title = "Quarterly finance outlook", createdAtLabel = "Other"),
    )

    override suspend fun loadHistoryPage(): List<HistoryRecord> = seedRecords

    override suspend fun deleteHistory(id: String): List<HistoryRecord> {
        return seedRecords.filterNot { it.id == id }
    }

    override suspend fun deleteAllHistory(): List<HistoryRecord> = emptyList()
}
