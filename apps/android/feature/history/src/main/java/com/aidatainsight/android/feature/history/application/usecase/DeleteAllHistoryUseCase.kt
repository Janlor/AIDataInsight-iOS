package com.aidatainsight.android.feature.history.application.usecase

import com.aidatainsight.android.feature.history.domain.HistoryRepository
import com.aidatainsight.android.feature.history.presentation.HistoryListBuilder
import com.aidatainsight.android.feature.history.presentation.HistorySectionUiModel

class DeleteAllHistoryUseCase(
    private val repository: HistoryRepository,
) {
    suspend operator fun invoke(): List<HistorySectionUiModel> {
        val records = repository.deleteAllHistory()
        val groups = HistoryListBuilder.groupRecords(records)
        return HistoryListBuilder.makeSections(groups)
    }
}
