package com.aidatainsight.android.feature.history.presentation

import com.aidatainsight.android.core.model.contract.HistoryRecord
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
                        displayTime = displayTime(record, group.title),
                    )
                },
            )
        }
    }

    private fun displayTime(
        record: HistoryRecord,
        sectionTitle: String,
    ): String {
        val source = record.updateTime ?: record.createTime ?: return ""
        return when (sectionTitle) {
            "今天" -> source.sliceIfAvailable(11, 16)
            "本月" -> source.sliceIfAvailable(5, 10)
            else -> source.sliceIfAvailable(0, 10)
        }
    }

    private fun String.sliceIfAvailable(
        start: Int,
        end: Int,
    ): String {
        return if (length >= end) substring(start, end) else ""
    }
}
