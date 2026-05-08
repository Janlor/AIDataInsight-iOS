//
//  SendFunctionMessageUseCase.swift
//  ModuleAI
//
//  Created by Codex on 2026/1/8.
//

import Foundation

struct SendFunctionMessageUseCase {
    private let repository: AIChatRepository

    init(repository: AIChatRepository) {
        self.repository = repository
    }

    func execute(
        text: String,
        historyId: Int?
    ) async throws -> UseCaseResult<SendFunctionMessageOutput> {
        let model = try await repository.sendFunctionMessage(text, historyId: historyId)

        guard let historyId = model.historyId else {
            return .failure(.message(model.msg))
        }

        guard let hasTool = model.hasTool,
              hasTool,
              let name = model.name,
              let arguments = model.arguments else {
            return .failure(.message(model.msg))
        }

        if let intentType = AIChatIntentResolver.resolve(arguments: arguments) {
            return .success(.intent(text: text, type: intentType))
        }

        return .success(.chartRequest(name: name, historyId: historyId, arguments: arguments))
    }
}
