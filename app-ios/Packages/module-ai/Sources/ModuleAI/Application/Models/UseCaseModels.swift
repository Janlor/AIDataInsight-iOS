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
    let sections: [HistorySectionViewData]
}

struct LoadTemplateOutput {
    let questions: [String]
}

struct LoadHistoryDetailOutput {
    let chats: [AIChat]
}

enum SendFunctionMessageOutput {
    case intent(text: String, type: AIChatIntentType)
    case chartRequest(name: FunctionName, historyId: Int, arguments: FunctionArguments)
}

struct LoadChartDataOutput {
    let funcType: FunctionName?
    let datas: [AIBarChartData]
}

struct DeleteHistoryOutput {
    let historyId: Int
    let state: HistoryStateSnapshot
}

struct StreamAIResponseOutput {
    let stream: AsyncThrowingStream<String, Error>
}
