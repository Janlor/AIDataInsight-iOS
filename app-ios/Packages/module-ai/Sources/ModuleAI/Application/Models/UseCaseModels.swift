//
//  UseCaseModels.swift
//  ModuleAI
//
//  Created by Codex on 2026/1/8.
//

import Foundation

enum UseCaseFailure: Equatable {
    case message(String?)
}

extension UseCaseFailure {
    var message: String? {
        switch self {
        case .message(let message):
            return message
        }
    }
}

enum UseCaseResult<Value> {
    case success(Value)
    case failure(UseCaseFailure)
}

struct HistoryStateSnapshot {
    let pageModel: RecordPageModel?
    let recordGroups: [HistoryRecordGroup]
}

struct LoadTemplateOutput {
    let questions: [String]
}

struct LoadHistoryDetailOutput {
    let messages: [ConversationMessage]
}

enum SendFunctionMessageOutput {
    case intent(text: String, type: AIChatIntentType)
    case chartRequest(name: FunctionName, historyId: Int, arguments: FunctionArguments)
}

struct LoadChartDataOutput {
    let payload: ChartPayload
}

struct DeleteHistoryOutput {
    let historyId: Int
    let state: HistoryStateSnapshot
}

struct StreamAIResponseOutput {
    let stream: AsyncThrowingStream<String, Error>
}

enum HistorySectionKind: Equatable {
    case today
    case thisMonth
    case other
}

struct HistoryRecordGroup: Equatable {
    let kind: HistorySectionKind
    var records: [RecordModel]
}

enum AIChatIntentType: Hashable {
    case time
    case index
}

enum ConversationRole: Hashable {
    case user
    case assistant
}

enum ConversationContentKind: Hashable {
    case welcome
    case text
    case intent
    case chart
}

enum FeedbackState: Hashable {
    case liked
    case disliked
    case none
    case unknown
}

enum ChartUnit: Hashable {
    case currency
    case ton
}

struct ConversationMessage: Hashable {
    let id: String
    let role: ConversationRole
    let contentKind: ConversationContentKind
    let text: String?
    let intentType: AIChatIntentType?
    let chartPayload: ChartPayload?
    let feedback: FeedbackState
    let historyDetailId: Int?
    let functionName: FunctionName?
}

struct ChartPayload: Hashable {
    let functionName: FunctionName?
    let unit: ChartUnit
    let series: [ChartSeries]
    let emptyMessage: String?
}

struct ChartSeries: Hashable {
    let xAxis: String
    let labels: [String]
    let values: [Double]
}
