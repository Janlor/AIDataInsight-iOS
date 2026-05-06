//
//  AIChatHistoryMapper.swift
//  ModuleAI
//
//  Created by Codex on 2026/1/1.
//

import Foundation

enum AIChatHistoryMapper {
    static func makeChats(from detailList: [DetailModel]) -> [AIChat] {
        DetailModel.decodeDetailList(detailList).map(mapToChat)
    }
    
    private static func mapToChat(_ model: DetailModel) -> AIChat {
        var isLike: Bool?
        if let like = model.isLike {
            isLike = like == "1"
        }
        
        if model.type == .question {
            return AIChat(text: model.content ?? "", type: .user)
        }
        
        if let chatModel = model.chatModel {
            let result = AIChatChartBuilder.build(from: chatModel)
            
            if let datas = result.0 {
                return AIChat(
                    text: "根据您的查询，以下是分析结果:",
                    type: .chart,
                    isLike: isLike,
                    barChartDatas: datas,
                    historyDetailId: model.id,
                    funcType: chatModel.funcType
                )
            }
            
            return AIChat(
                text: result.1 ?? "数据分析还在测试阶段，很快就能上线，敬请期待！",
                type: .ai
            )
        }
        
        if let funcModel = model.funcModel {
            return AIChat(text: funcModel.msg ?? "", type: .ai)
        }
        
        return AIChat(
            text: model.content ?? "新版本上线啦，升级后我会变得更聪明，快来体验吧！",
            type: .ai
        )
    }
}
