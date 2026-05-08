package com.aidatainsight.android.feature.history.presentation

import com.aidatainsight.android.core.model.history.HistoryRecord
import com.aidatainsight.android.core.model.history.HistoryRecordGroup

object HistoryListBuilder {
    fun groupRecords(records: List<HistoryRecord>): List<HistoryRecordGroup> {
        return records
            .groupBy { it.createdAtLabel }
            .map { (title, items) -> HistoryRecordGroup(title = title, records = items) }
    }

    fun makeSections(groups: List<HistoryRecordGroup>): List<HistorySectionUiModel> {
        return groups.map { group ->
            HistorySectionUiModel(
                title = group.title,
                items = group.records.map { record ->
                    HistoryItemUiModel(
                        id = record.id,
                        title = record.title,
                    )
                },
            )
        }
    }
}
