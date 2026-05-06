//
//  AIChatIntentResolver.swift
//  ModuleAI
//
//  Created by Codex on 2026/1/1.
//

import Foundation

enum AIChatIntentResolver {
    static func resolve(text: String, arguments: FunctionArguments) -> FunctionResult? {
        switch arguments {
        case .timeRange(let timeRange):
            if timeRange.startDate == nil {
                return .intent(text: text, type: .time)
            }
        case .performanceType:
            return .intent(text: text, type: .index)
        default:
            break
        }
        
        return nil
    }
}
