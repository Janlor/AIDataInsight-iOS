//
//  AIChatIntentResolver.swift
//  ModuleAI
//
//  Created by Codex on 2026/1/1.
//

import Foundation

enum AIChatIntentResolver {
    static func resolve(arguments: FunctionArguments) -> AIChatIntentType? {
        switch arguments {
        case .timeRange(let timeRange):
            if timeRange.startDate == nil {
                return .time
            }
        case .performanceType:
            return .index
        default:
            break
        }
        
        return nil
    }
}

