import Foundation
@testable import ModuleAI

struct MockHistoryRepository: HistoryRepository {
    var pageModel: RecordPageModel = RecordPageModel(
        currentPage: 1,
        pageSize: 50,
        total: 0,
        pages: 0,
        cacheKey: nil,
        records: []
    )
    var deleteHistoryHandler: ((Int) throws -> Void)?
    var didDeleteAllHistory = false

    func loadHistoryPage(pageNo: Int, pageSize: Int) async throws -> RecordPageModel {
        pageModel
    }

    func deleteHistory(historyId: Int) async throws {
        try deleteHistoryHandler?(historyId)
    }

    func deleteAllHistory() async throws {}
}
