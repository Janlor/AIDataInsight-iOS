package com.aidatainsight.android.feature.history.application.model

import com.aidatainsight.android.core.model.contract.HistoryRecord
import com.aidatainsight.android.core.model.contract.RecordPage

data class HistoryStateSnapshot(
    val page: RecordPage?,
    val groups: List<HistoryRecordGroup>,
)

data class DeleteHistoryOutput(
    val deletedHistoryId: Int,
    val state: HistoryStateSnapshot,
)

data class HistoryRecordGroup(
    val title: String,
    val records: List<HistoryRecord>,
)

