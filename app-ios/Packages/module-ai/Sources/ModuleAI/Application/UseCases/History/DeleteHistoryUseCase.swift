//
//  DeleteHistoryUseCase.swift
//  ModuleAI
//
//  Created by Codex on 2026/1/8.
//

import Foundation
import UIKit
import CommonViewModel

struct DeleteHistoryUseCase {
    private let repository: HistoryRepository

    init(repository: HistoryRepository) {
        self.repository = repository
    }

    func execute(
        recordGroups: [HistoryRecordGroup],
        indexPath: IndexPath
    ) async throws -> DeleteHistoryOutput {
        let history = recordGroups[indexPath.section].records[indexPath.row]
        guard let historyId = history.id else {
            throw CommonRequesterError.requestFailed
        }

        try await repository.deleteHistory(historyId: historyId)

        var updatedGroups = recordGroups
        updatedGroups[indexPath.section].records.remove(at: indexPath.row)
        if updatedGroups[indexPath.section].records.isEmpty {
            updatedGroups.remove(at: indexPath.section)
        }

        return DeleteHistoryOutput(
            historyId: historyId,
            state: HistoryStateSnapshot(
                pageModel: nil,
                recordGroups: updatedGroups,
                sections: HistoryListViewDataBuilder.makeSections(from: updatedGroups)
            )
        )
    }
}
