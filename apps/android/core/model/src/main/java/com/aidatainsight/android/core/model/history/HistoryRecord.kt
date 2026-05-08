package com.aidatainsight.android.core.model.history

data class HistoryRecord(
    val id: String,
    val title: String,
    val createdAtLabel: String,
)

data class HistoryRecordGroup(
    val title: String,
    val records: List<HistoryRecord>,
)
