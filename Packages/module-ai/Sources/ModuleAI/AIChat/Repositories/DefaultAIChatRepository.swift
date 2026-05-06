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
        try await CommonRequester.requestNet(ChatApi.function(text, historyId))
    }
    
    func loadChartData(name: FunctionName, historyId: Int, arguments: any DictionaryConvertible) async throws -> HistoryDetailModel {
        try await CommonRequester.requestNet(ChartApi.chart(name.rawValue, historyId, arguments))
    }
    
    func sendLikeFeedback(historyDetailId: Int, like: String) async throws {
        try await CommonRequester.requestVoid(HistoryApi.like(historyDetailId, like))
    }
    
    func streamMessage(_ text: String) -> AsyncThrowingStream<String, Error> {
        do {
            let request = try makeStreamRequest(text: text)
            return CommonRequester.requestSSE(request)
        } catch {
            return AsyncThrowingStream { continuation in
                continuation.finish(throwing: error)
            }
        }
    }
}

private extension DefaultAIChatRepository {
    func makeStreamRequest(text: String) throws -> URLRequest {
        let urlString = "https://m1.apifoxmock.com/m1/3174267-1700689-default/stream"
        guard var components = URLComponents(string: urlString) else {
            throw CommonRequesterError.requestFailed
        }
        
        components.queryItems = [
            URLQueryItem(name: "question", value: text)
        ]
        
        guard let url = components.url else {
            throw CommonRequesterError.requestFailed
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        return request
    }
}
