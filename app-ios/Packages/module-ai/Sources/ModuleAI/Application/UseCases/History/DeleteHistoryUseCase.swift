//
//  DeleteHistoryUseCase.swift
//  ModuleAI
//
//  Created by Codex on 2026/1/8.
//

import Foundation

struct DeleteHistoryUseCase {
    private let repository: HistoryRepository

    init(repository: HistoryRepository) {
        self.repository = repository
    }

    func execute(
        recordGroups: [HistoryRecordGroup],
        historyId: Int
    ) async throws -> DeleteHistoryOutput {
        try await repository.deleteHistory(historyId: historyId)

        let updatedGroups = recordGroups.compactMap { group -> HistoryRecordGroup? in
            let records = group.records.filter { $0.id != historyId }
            guard records.isEmpty == false else { return nil }
            return HistoryRecordGroup(kind: group.kind, records: records)
        }

        return DeleteHistoryOutput(
            historyId: historyId,
            state: HistoryStateSnapshot(
                pageModel: nil,
                recordGroups: updatedGroups
            )
        )
    }
}
