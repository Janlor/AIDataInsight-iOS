//
//  LoadHistoryDetailUseCase.swift
//  ModuleAI
//
//  Created by Codex on 2026/1/8.
//

import Foundation

struct LoadHistoryDetailUseCase {
    private let repository: AIChatRepository

    init(repository: AIChatRepository) {
        self.repository = repository
    }

    func execute(historyId: Int) async throws -> [AIChat] {
        let record = try await repository.loadHistoryDetail(historyId)
        return AIChatHistoryMapper.makeChats(from: record.detailList ?? [])
    }
}
