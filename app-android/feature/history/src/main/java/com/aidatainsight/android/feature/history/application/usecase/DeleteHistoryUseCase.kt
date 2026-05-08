package com.aidatainsight.android.feature.history.application.usecase

import com.aidatainsight.android.feature.history.domain.HistoryRepository
import com.aidatainsight.android.feature.history.presentation.HistoryListBuilder
import com.aidatainsight.android.feature.history.presentation.HistorySectionUiModel

class DeleteHistoryUseCase(
    private val repository: HistoryRepository,
) {
    suspend operator fun invoke(id: String): List<HistorySectionUiModel> {
        val records = repository.deleteHistory(id)
        val groups = HistoryListBuilder.groupRecords(records)
        return HistoryListBuilder.makeSections(groups)
    }
}
