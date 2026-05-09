package com.aidatainsight.android.feature.history.presentation

import com.aidatainsight.android.feature.history.application.model.HistoryRecordGroup

object HistoryListBuilder {
    fun makeSections(groups: List<HistoryRecordGroup>): List<HistorySectionUiModel> {
        return groups.map { group ->
            HistorySectionUiModel(
                title = group.title,
                items = group.records.map { record ->
                    HistoryItemUiModel(
                        id = record.id?.toString().orEmpty(),
                        title = record.name.orEmpty(),
                    )
                },
            )
        }
    }
}
