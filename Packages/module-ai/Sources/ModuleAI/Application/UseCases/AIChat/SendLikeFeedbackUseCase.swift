//
//  SendLikeFeedbackUseCase.swift
//  ModuleAI
//
//  Created by Codex on 2026/1/8.
//

import Foundation

struct SendLikeFeedbackUseCase {
    private let repository: AIChatRepository

    init(repository: AIChatRepository) {
        self.repository = repository
    }

    func execute(historyDetailId: Int, like: String) async throws {
        try await repository.sendLikeFeedback(historyDetailId: historyDetailId, like: like)
    }
}
