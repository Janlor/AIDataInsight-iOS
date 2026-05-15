package com.aidatainsight.android.feature.history.application

import com.aidatainsight.android.core.model.contract.HistoryRecord
import com.aidatainsight.android.core.model.contract.RecordPage
import com.aidatainsight.android.feature.history.application.model.HistoryRecordGroup
import com.aidatainsight.android.feature.history.application.usecase.DeleteAllHistoryUseCase
import com.aidatainsight.android.feature.history.application.usecase.DeleteHistoryUseCase
import com.aidatainsight.android.feature.history.application.usecase.LoadHistoryPageUseCase
import com.aidatainsight.android.feature.history.domain.HistoryRepository
import kotlinx.coroutines.runBlocking
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class HistoryUseCaseTest {
    @Test
    fun loadHistoryPage_pageOneReplacesExistingGroups() = runBlocking {
        val repository = FakeHistoryRepository(
            page = RecordPage(
                currentPage = 1,
                pageSize = 20,
                records = listOf(record(id = 1, name = "今天记录", updateTime = todayText())),
            ),
        )
        val useCase = LoadHistoryPageUseCase(repository)

        val snapshot = useCase(
            currentPage = 1,
            pageSize = 20,
            existingGroups = listOf(
                HistoryRecordGroup(title = "其它", records = listOf(record(id = 99))),
            ),
        )

        assertEquals(1, snapshot.groups.sumOf { it.records.size })
        assertEquals(1, snapshot.groups.single().records.single().id)
    }

    @Test
    fun loadHistoryPage_pageGreaterThanOneAppendsGroups() = runBlocking {
        val repository = FakeHistoryRepository(
            page = RecordPage(
                currentPage = 2,
                pageSize = 20,
                records = listOf(record(id = 2, name = "追加记录", updateTime = "2026-01-01 09:00:00")),
            ),
        )
        val useCase = LoadHistoryPageUseCase(repository)

        val snapshot = useCase(
            currentPage = 2,
            pageSize = 20,
            existingGroups = listOf(
                HistoryRecordGroup(title = "其它", records = listOf(record(id = 1, updateTime = "2026-01-02 09:00:00"))),
            ),
        )

        assertEquals(1, snapshot.groups.size)
        assertEquals(listOf(1, 2), snapshot.groups.single().records.map { it.id })
    }

    @Test
    fun deleteHistory_removesRecordAndEmptyGroupAfterRemoteSuccess() = runBlocking {
        val repository = FakeHistoryRepository()
        val useCase = DeleteHistoryUseCase(repository)

        val output = useCase(
            historyId = 1,
            existingGroups = listOf(
                HistoryRecordGroup(title = "今天", records = listOf(record(id = 1))),
                HistoryRecordGroup(title = "其它", records = listOf(record(id = 2))),
            ),
        )

        assertEquals(1, output.deletedHistoryId)
        assertEquals(listOf(2), output.state.groups.flatMap { it.records }.map { it.id })
        assertEquals(listOf(1), repository.deletedIds)
    }

    @Test
    fun deleteAllHistory_returnsEmptyGroups() = runBlocking {
        val repository = FakeHistoryRepository()
        val useCase = DeleteAllHistoryUseCase(repository)

        val snapshot = useCase()

        assertTrue(snapshot.groups.isEmpty())
        assertTrue(repository.deletedAll)
    }

    private fun todayText(): String {
        return java.time.LocalDate.now().atTime(9, 0)
            .format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"))
    }
}

private class FakeHistoryRepository(
    private val page: RecordPage = RecordPage(records = emptyList()),
) : HistoryRepository {
    val deletedIds = mutableListOf<Int>()
    var deletedAll = false

    override suspend fun loadHistoryPage(currentPage: Int, pageSize: Int): RecordPage = page

    override suspend fun deleteHistory(historyId: Int) {
        deletedIds += historyId
    }

    override suspend fun deleteAllHistory() {
        deletedAll = true
    }
}

private fun record(
    id: Int,
    name: String = "记录$id",
    updateTime: String = "2026-01-01 09:00:00",
): HistoryRecord {
    return HistoryRecord(
        id = id,
        name = name,
        updateTime = updateTime,
    )
}
