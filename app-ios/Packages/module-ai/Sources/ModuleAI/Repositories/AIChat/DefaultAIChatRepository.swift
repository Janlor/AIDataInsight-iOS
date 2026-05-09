//
//  DefaultAIChatRepository.swift
//  ModuleAI
//
//  Created by Codex on 2026/1/1.
//

import Foundation
import BaseKit
import CommonViewModel

struct DefaultAIChatRepository: AIChatRepository {
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    func loadTemplate() async throws -> TemplateModel {
        let string: String = try await CommonRequester.requestNet(ChatApi.template)
        guard let data = string.data(using: .utf8) else {
            throw CommonRequesterError.emptyResponse
        }
        return try decoder.decode(TemplateModel.self, from: data)
    }
    
    func loadHistoryDetail(_ historyId: Int) async throws -> RecordModel {
        try await CommonRequester.requestNet(HistoryApi.detail(historyId))
    }
    
    func sendFunctionMessage(_ text: String, historyId: Int?) async throws -> FunctionModel {
        let dto: FunctionResponseDTO = try await CommonRequester.requestNet(ChatApi.function(text, historyId))
        return dto.toDomainModel()
    }
    
    func loadChartData(name: FunctionName, historyId: Int, arguments: FunctionArguments) async throws -> HistoryDetailModel {
        try await CommonRequester.requestNet(ChartApi.chart(name, historyId, arguments))
    }
    
    func sendLikeFeedback(historyDetailId: Int, like: String) async throws {
        try await CommonRequester.requestVoid(HistoryApi.like(historyDetailId, like))
    }
    
    func streamMessage(_ text: String) -> AsyncThrowingStream<String, Error> {
        CommonRequester.requestSSE(ChatApi.stream(text))
    }
}
