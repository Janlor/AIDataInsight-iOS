package com.aidatainsight.android.feature.history.application

import com.aidatainsight.android.core.model.contract.HistoryRecord
import com.aidatainsight.android.feature.history.application.model.HistoryRecordGroup
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.YearMonth
import java.time.format.DateTimeFormatter
import java.time.format.DateTimeParseException

object HistoryApplicationMapper {
    private val dateTimeFormatter: DateTimeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")

    fun groupRecords(records: List<HistoryRecord>?): List<HistoryRecordGroup> {
        if (records.isNullOrEmpty()) return emptyList()

        val groups = mutableListOf<HistoryRecordGroup>()
        var currentTitle: String? = null
        var currentRecords = mutableListOf<HistoryRecord>()

        records.forEach { record ->
            val title = titleFor(record.updateTime ?: record.createTime)
            if (title == null) return@forEach

            if (title != currentTitle) {
                if (currentTitle != null && currentRecords.isNotEmpty()) {
                    groups += HistoryRecordGroup(title = currentTitle.orEmpty(), records = currentRecords)
                }
                currentTitle = title
                currentRecords = mutableListOf(record)
            } else {
                currentRecords += record
            }
        }

        if (currentTitle != null && currentRecords.isNotEmpty()) {
            groups += HistoryRecordGroup(title = currentTitle.orEmpty(), records = currentRecords)
        }

        return groups
    }

    fun mergeGroups(
        existing: List<HistoryRecordGroup>,
        new: List<HistoryRecordGroup>,
    ): List<HistoryRecordGroup> {
        if (existing.isEmpty()) return new
        val merged = existing.toMutableList()
        new.forEach { newGroup ->
            val existingIndex = merged.indexOfLast { it.title == newGroup.title }
            if (existingIndex >= 0) {
                val existingGroup = merged[existingIndex]
                merged[existingIndex] = existingGroup.copy(
                    records = existingGroup.records + newGroup.records,
                )
            } else {
                merged += newGroup
            }
        }
        return merged
    }

    private fun titleFor(value: String?): String? {
        val date = parseDate(value) ?: return null
        val today = LocalDate.now()
        return when {
            date == today -> "今天"
            YearMonth.from(date) == YearMonth.from(today) -> "本月"
            else -> "其它"
        }
    }

    private fun parseDate(value: String?): LocalDate? {
        if (value.isNullOrBlank()) return null
        return try {
            LocalDateTime.parse(value, dateTimeFormatter).toLocalDate()
        } catch (_: DateTimeParseException) {
            runCatching { LocalDate.parse(value) }.getOrNull()
        }
    }
}
