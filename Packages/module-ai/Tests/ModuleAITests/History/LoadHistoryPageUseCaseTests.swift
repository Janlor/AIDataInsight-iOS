import Foundation
import UIKit
import Testing
@testable import ModuleAI

struct LoadHistoryPageUseCaseTests {
    @Test
    func execute_firstPage_replacesExistingGroups() async throws {
        let useCase = LoadHistoryPageUseCase(
            repository: MockHistoryRepository(
                pageModel: RecordPageModel(
                    currentPage: 1,
                    pageSize: 50,
                    total: 1,
                    pages: 1,
                    cacheKey: nil,
                    records: [record(id: 1, name: "今天", updateTime: "2025-01-31 10:30:00")]
                )
            ),
            dateFormatter: makeDateFormatter()
        )

        let state = try await useCase.execute(
            pageNo: 1,
            pageSize: 50,
            existingGroups: [
                HistoryRecordGroup(
                    kind: .other,
                    records: [record(id: 99, name: "旧数据", updateTime: "2024-01-01 10:00:00")]
                )
            ]
        )

        #expect(state.pageModel?.currentPage == 1)
        #expect(state.recordGroups.count == 1)
        #expect(state.sections.count == 1)
        #expect(state.recordGroups[0].records.map(\.id) == [1])
    }

    @Test
    func execute_nextPage_mergesIntoExistingGroups() async throws {
        let useCase = LoadHistoryPageUseCase(
            repository: MockHistoryRepository(
                pageModel: RecordPageModel(
                    currentPage: 2,
                    pageSize: 50,
                    total: 2,
                    pages: 2,
                    cacheKey: nil,
                    records: [record(id: 2, name: "新增", updateTime: "2025-01-31 11:30:00")]
                )
            ),
            dateFormatter: makeDateFormatter()
        )

        let state = try await useCase.execute(
            pageNo: 2,
            pageSize: 50,
            existingGroups: [
                HistoryRecordGroup(
                    kind: .today,
                    records: [record(id: 1, name: "已有", updateTime: "2025-01-31 10:30:00")]
                )
            ]
        )

        #expect(state.recordGroups.count == 1)
        #expect(state.sections.count == 1)
        #expect(state.recordGroups[0].records.map(\.id) == [1, 2])
    }
}

private extension LoadHistoryPageUseCaseTests {
    func makeDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }

    func record(id: Int, name: String, updateTime: String) -> RecordModel {
        RecordModel(
            id: id,
            name: name,
            createId: nil,
            updateId: nil,
            createName: nil,
            updateName: nil,
            createTime: nil,
            updateTime: updateTime,
            detailList: nil
        )
    }
}
