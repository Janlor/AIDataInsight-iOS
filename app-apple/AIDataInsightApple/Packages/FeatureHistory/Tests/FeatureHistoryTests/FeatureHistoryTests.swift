import Testing
import AppContracts
import Foundation
@testable import FeatureHistory

@MainActor
@Test func historyStoreDeletesConversation() {
    let store = HistoryStore(conversations: [
        HistoryConversationViewState(id: "1", title: "A"),
        HistoryConversationViewState(id: "2", title: "B"),
    ])

    store.delete(id: "1")
    #expect(store.conversations.map(\.id) == ["2"])
}

@MainActor
@Test func historyStoreLoadsAndGroupsRecords() async {
    let store = HistoryStore(repository: PreviewHistoryRepository())

    await store.loadFirstPage()

    #expect(store.state.groups.isEmpty == false)
    #expect(store.conversations.first?.title == "欢迎使用 AI 数据分析助手")
}

@MainActor
@Test func deletingSelectedHistoryClearsSelection() async {
    let store = HistoryStore(repository: StaticHistoryRepository(records: [
        HistoryRecordContract(id: 7, name: "A", updateTime: ISO8601DateFormatter().string(from: .now), detailList: nil),
    ]))
    await store.loadFirstPage()
    store.select(historyID: 7)

    let deletedSelected = await store.delete(historyID: 7)

    #expect(deletedSelected)
    #expect(store.selectedID == nil)
    #expect(store.conversations.isEmpty)
}

private struct StaticHistoryRepository: HistoryRepository {
    let records: [HistoryRecordContract]

    func loadHistoryPage(currentPage: Int, pageSize: Int) async throws -> RecordPageContract {
        RecordPageContract(currentPage: currentPage, pageSize: pageSize, total: records.count, pages: 1, cacheKey: nil, records: records)
    }

    func deleteHistory(historyId: Int) async throws {}

    func deleteAllHistory() async throws {}
}
