package com.aidatainsight.android.feature.history.application.usecase

import com.aidatainsight.android.feature.history.application.model.HistoryStateSnapshot
import com.aidatainsight.android.feature.history.domain.HistoryRepository

class DeleteAllHistoryUseCase(
    private val repository: HistoryRepository,
) {
    suspend operator fun invoke(): HistoryStateSnapshot {
        repository.deleteAllHistory()
        return HistoryStateSnapshot(page = null, groups = emptyList())
    }
}
