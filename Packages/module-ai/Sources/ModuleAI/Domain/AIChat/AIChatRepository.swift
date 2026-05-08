//
//  AIChatRepository.swift
//  ModuleAI
//
//  Created by Codex on 2026/1/1.
//

import Foundation

protocol AIChatRepository {
    func loadTemplate() async throws -> TemplateModel
    func loadHistoryDetail(_ historyId: Int) async throws -> RecordModel
    func sendFunctionMessage(_ text: String, historyId: Int?) async throws -> FunctionModel
    func loadChartData(name: FunctionName, historyId: Int, arguments: FunctionArguments) async throws -> HistoryDetailModel
    func sendLikeFeedback(historyDetailId: Int, like: String) async throws
    func streamMessage(_ text: String) -> AsyncThrowingStream<String, Error>
}
