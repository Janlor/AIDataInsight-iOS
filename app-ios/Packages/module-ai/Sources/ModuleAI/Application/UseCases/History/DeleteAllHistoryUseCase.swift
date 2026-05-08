//
//  DeleteAllHistoryUseCase.swift
//  ModuleAI
//
//  Created by Codex on 2026/1/8.
//

import Foundation

struct DeleteAllHistoryUseCase {
    private let repository: HistoryRepository

    init(repository: HistoryRepository) {
        self.repository = repository
    }

    func execute() async throws -> HistoryStateSnapshot {
        try await repository.deleteAllHistory()
        return HistoryStateSnapshot(
            pageModel: nil,
            recordGroups: []
        )
    }
}
