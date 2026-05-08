//
//  AIChatHistoryMapper.swift
//  ModuleAI
//
//  Created by Codex on 2026/1/1.
//

import Foundation

enum AIChatHistoryMapper {
    static func makeChats(from messages: [ConversationMessage]) -> [AIChat] {
        messages.map(mapToChat)
    }
    
    private static func mapToChat(_ message: ConversationMessage) -> AIChat {
        switch message.contentKind {
        case .welcome:
            return AIChat(
                text: message.text ?? "",
                type: .welcome
            )
        case .text:
            return AIChat(
                text: message.text ?? "",
                type: message.role == .user ? .user : .ai,
                isLike: isLike(from: message.feedback),
                historyDetailId: message.historyDetailId,
                funcType: message.functionName
            )
        case .intent:
            return AIChat(
                text: message.text ?? "",
                type: .intent,
                intentType: message.intentType,
                historyDetailId: message.historyDetailId,
                funcType: message.functionName
            )
        case .chart:
            return AIChat(
                text: message.text ?? "根据您的查询，以下是分析结果:",
                type: .chart,
                isLike: isLike(from: message.feedback),
                barChartDatas: message.chartPayload.map(AIChatChartBuilder.build),
                historyDetailId: message.historyDetailId,
                funcType: message.functionName
            )
        }
    }
    
    private static func isLike(from feedback: FeedbackState) -> Bool? {
        switch feedback {
        case .liked:
            return true
        case .disliked:
            return false
        case .none, .unknown:
            return nil
        }
    }
}
