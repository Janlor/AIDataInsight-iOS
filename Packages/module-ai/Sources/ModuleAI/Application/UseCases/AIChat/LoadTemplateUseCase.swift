//
//  LoadTemplateUseCase.swift
//  ModuleAI
//
//  Created by Codex on 2026/1/8.
//

import Foundation

struct LoadTemplateUseCase {
    private let repository: AIChatRepository

    init(repository: AIChatRepository) {
        self.repository = repository
    }

    func execute() async throws -> [String] {
        let template = try await repository.loadTemplate()
        return template.questions
    }
}
