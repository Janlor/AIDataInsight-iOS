import Foundation
import Testing
@testable import ModuleAI

@Suite(.serialized)
struct HistoryViewModelTests {
    @MainActor
    @Test
    func reloadData_failure_emitsLocalizedError() async {
        let viewModel = HistoryViewModel(
            repository: MockHistoryRepository(pageError: TestError.failed)
        )
        let recorder = StringRecorder()

        viewModel.onDataLoadFailed = { message in
            Task { await recorder.record(message) }
        }

        await viewModel.reloadData()
        let result = await recorder.waitForValue()

        #expect(result?.isEmpty == false)
    }

    @MainActor
    @Test
    func deleteAllHistory_clearsExistingState() async throws {
        let viewModel = HistoryViewModel(
            repository: MockHistoryRepository(
                pageModel: RecordPageModel(
                    currentPage: 1,
                    pageSize: 50,
                    total: 1,
                    pages: 1,
                    cacheKey: nil,
                    records: [
                        RecordModel(
                            id: 1,
                            name: "A",
                            createId: nil,
                            updateId: nil,
                            createName: nil,
                            updateName: nil,
                            createTime: nil,
                            updateTime: "2025-01-31 10:30:00",
                            detailList: nil
                        )
                    ]
                )
            )
        )

        await viewModel.reloadData()
        #expect(viewModel.sections.isEmpty == false)

        try await viewModel.deleteAllHistory()

        #expect(viewModel.sections.isEmpty)
        #expect(viewModel.recordGroups.isEmpty)
        #expect(viewModel.pageModel == nil)
    }
}

private enum TestError: LocalizedError {
    case failed

    var errorDescription: String? {
        "history failed"
    }
}

private actor StringRecorder {
    private var value: String??
    private var continuation: CheckedContinuation<String?, Never>?

    func record(_ value: String?) {
        self.value = value
        continuation?.resume(returning: value)
        continuation = nil
    }

    func waitForValue() async -> String? {
        if let value {
            return value
        }
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }
}
