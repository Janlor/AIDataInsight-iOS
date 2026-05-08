import Foundation
@testable import ModuleAI

struct MockHistoryRepository: HistoryRepository {
    var pageError: Error?
    var pageModel: RecordPageModel = RecordPageModel(
        currentPage: 1,
        pageSize: 50,
        total: 0,
        pages: 0,
        cacheKey: nil,
        records: []
    )
    var deleteHistoryHandler: ((Int) throws -> Void)?
    var deleteAllHistoryHandler: (() throws -> Void)?

    func loadHistoryPage(pageNo: Int, pageSize: Int) async throws -> RecordPageModel {
        if let pageError {
            throw pageError
        }
        return pageModel
    }

    func deleteHistory(historyId: Int) async throws {
        try deleteHistoryHandler?(historyId)
    }

    func deleteAllHistory() async throws {
        try deleteAllHistoryHandler?()
    }
}
