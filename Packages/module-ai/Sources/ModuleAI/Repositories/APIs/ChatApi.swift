//
//  ChatApi.swift
//  ModuleAI
//
//  Created by Janlor on 2024/10/29.
//

import Foundation
import Networking

enum ChatApi: RequestDescriptor {
    /// 函数调用分析
    case function(String, Int?)
    /// 聊天模板配置
    case template
    
    var path: String {
        switch self {
        case .function(_,_):
            return "/chat/function"
        case .template:
            return "/chat/template"
        }
    }
    
    var method: Networking.Method {
        return .get
    }
    
    var parameters: [String : Any] {
        switch self {
        case .function(let question, let historyId):
            var params: [String : Any] = [
                "question": question,
            ]
            if let historyId = historyId {
                // 历史会话id
                params["historyId"] = historyId
            }
            return params
        case .template:
            return [:]
        }
    }
}
