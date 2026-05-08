//
//  StreamAIResponseUseCase.swift
//  ModuleAI
//
//  Created by Codex on 2026/1/8.
//

import Foundation

struct StreamAIResponseUseCase {
    private let repository: AIChatRepository

    init(repository: AIChatRepository) {
        self.repository = repository
    }

    func execute(text: String) -> StreamAIResponseOutput {
        StreamAIResponseOutput(stream: repository.streamMessage(text))
    }
}
