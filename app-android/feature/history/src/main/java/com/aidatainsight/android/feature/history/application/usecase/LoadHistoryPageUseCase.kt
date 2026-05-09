package com.aidatainsight.android.feature.history.application.usecase

import com.aidatainsight.android.feature.history.application.HistoryApplicationMapper
import com.aidatainsight.android.feature.history.application.model.HistoryRecordGroup
import com.aidatainsight.android.feature.history.application.model.HistoryStateSnapshot
import com.aidatainsight.android.feature.history.domain.HistoryRepository

class LoadHistoryPageUseCase(
    private val repository: HistoryRepository,
) {
    suspend operator fun invoke(
        currentPage: Int,
        pageSize: Int,
        existingGroups: List<HistoryRecordGroup>,
    ): HistoryStateSnapshot {
        val page = repository.loadHistoryPage(currentPage = currentPage, pageSize = pageSize)
        val newGroups = HistoryApplicationMapper.groupRecords(page.records)
        val groups = if ((page.currentPage ?: currentPage) == 1 || existingGroups.isEmpty()) {
            newGroups
        } else {
            HistoryApplicationMapper.mergeGroups(existingGroups, newGroups)
        }
        return HistoryStateSnapshot(page = page, groups = groups)
    }
}
