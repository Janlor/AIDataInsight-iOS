//
//  AIChatIntentResolver.swift
//  ModuleAI
//
//  Created by Codex on 2026/1/1.
//

import Foundation

enum AIChatIntentResolver {
    static func resolve(text: String, arguments: Codable) -> FunctionResult? {
        switch arguments {
        case let timeRange as TimeRangeQueryModel:
            if timeRange.startDate == nil {
                return .intent(text: text, type: .time)
            }
        case _ as PerformanceTypeQueryModel:
            return .intent(text: text, type: .index)
        default:
            break
        }
        
        return nil
    }
}
