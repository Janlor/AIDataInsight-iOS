import Foundation
import UIKit
import Testing
@testable import ModuleAI

struct DeleteHistoryUseCaseTests {
    @Test
    func execute_removesRecordAndReturnsHistoryId() async throws {
        let useCase = DeleteHistoryUseCase(repository: MockHistoryRepository())
        let groups = [
            HistoryRecordGroup(
                kind: .today,
                records: [
                    record(id: 1, name: "A", updateTime: "2025-01-31 10:30:00"),
                    record(id: 2, name: "B", updateTime: "2025-01-31 11:30:00")
                ]
            )
        ]

        let output = try await useCase.execute(
            recordGroups: groups,
            indexPath: IndexPath(row: 0, section: 0)
        )

        #expect(output.historyId == 1)
        #expect(output.state.recordGroups.count == 1)
        #expect(output.state.recordGroups[0].records.map(\.id) == [2])
        #expect(output.state.sections.count == 1)
    }

    @Test
    func execute_removesEmptySection() async throws {
        let useCase = DeleteHistoryUseCase(repository: MockHistoryRepository())
        let groups = [
            HistoryRecordGroup(
                kind: .today,
                records: [record(id: 1, name: "A", updateTime: "2025-01-31 10:30:00")]
            )
        ]

        let output = try await useCase.execute(
            recordGroups: groups,
            indexPath: IndexPath(row: 0, section: 0)
        )

        #expect(output.state.recordGroups.isEmpty)
        #expect(output.state.sections.isEmpty)
    }
}

private extension DeleteHistoryUseCaseTests {
    func record(id: Int?, name: String, updateTime: String) -> RecordModel {
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
