//
//  AIChat.swift
//  ModuleAI
//
//  Created by Janlor on 2024/10/24.
//

import Foundation

enum AIChatType: Hashable {
    case welcome
    case user
    case ai
    case intent
    case chart
}

enum AIChatIntentType: Hashable {
    case time
    case index
}

struct AIChat: Hashable {
    let id: UUID
    var text: String
    let type: AIChatType
    let intentType: AIChatIntentType
    let questions: [String]
    var isLike: Bool?
    let barChartDatas: [AIBarChartData]?
    let historyDetailId: Int? // 业务ID
    let funcType: FunctionName?
    
    var unitString: String {
        guard let funcType = funcType else { return "元" }
        switch funcType {
        case .queryStockGroupByOrg, .queryStockGroupByWarehouse:
            return "吨"
        default:
            return "元"
        }
    }
    
    
    init(id: UUID = UUID(),
         text: String,
         type: AIChatType,
         intentType: AIChatIntentType? = nil,
         questions: [String] = [],
         isLike: Bool? = nil,
         barChartDatas: [AIBarChartData]? = nil,
         historyDetailId: Int? = nil,
         funcType: FunctionName? = nil) {
        self.id = id
        self.text = text
        self.type = type
        self.intentType = intentType ?? .time
        self.questions = questions
        self.isLike = isLike
        self.barChartDatas = barChartDatas
        self.historyDetailId = historyDetailId
        self.funcType = funcType
    }
    
    static func == (lhs: AIChat, rhs: AIChat) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
