//
//  SendFunctionMessageUseCase.swift
//  ModuleAI
//
//  Created by Codex on 2026/1/8.
//

import Foundation

enum SendFunctionMessageUseCaseResult {
    case intent(text: String, type: AIChatIntentType)
    case chartRequest(name: FunctionName, historyId: Int, arguments: FunctionArguments)
    case failure(String?)
}

struct SendFunctionMessageUseCase {
    private let repository: AIChatRepository

    init(repository: AIChatRepository) {
        self.repository = repository
    }

    func execute(
        text: String,
        historyId: Int?
    ) async throws -> SendFunctionMessageUseCaseResult {
        let model = try await repository.sendFunctionMessage(text, historyId: historyId)

        guard let historyId = model.historyId else {
            return .failure(model.msg)
        }

        guard let hasTool = model.hasTool,
              hasTool,
              let name = model.name,
              let arguments = model.arguments else {
            return .failure(model.msg)
        }

        if let intentType = AIChatIntentResolver.resolve(arguments: arguments) {
            return .intent(text: text, type: intentType)
        }

        return .chartRequest(name: name, historyId: historyId, arguments: arguments)
    }
}
