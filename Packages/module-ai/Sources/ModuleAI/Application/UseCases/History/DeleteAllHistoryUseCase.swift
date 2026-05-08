//
//  DeleteAllHistoryUseCase.swift
//  ModuleAI
//
//  Created by Codex on 2026/1/8.
//

import Foundation

struct DeleteAllHistoryUseCaseResult {
    let recordGroups: [HistoryRecordGroup]
    let sections: [HistorySectionViewData]
    let pageModel: RecordPageModel?
}

struct DeleteAllHistoryUseCase {
    private let repository: HistoryRepository

    init(repository: HistoryRepository) {
        self.repository = repository
    }

    func execute() async throws -> DeleteAllHistoryUseCaseResult {
        try await repository.deleteAllHistory()
        return DeleteAllHistoryUseCaseResult(
            recordGroups: [],
            sections: [],
            pageModel: nil
        )
    }
}
