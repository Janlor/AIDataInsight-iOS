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
    /// AI 流式回复
    case stream(String)
    
    var path: String {
        switch self {
        case .function(_,_):
            return "/chat/function"
        case .template:
            return "/chat/template"
        case .stream:
            return AIChatEndpoint.streamPath
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
        case .stream(let question):
            return [
                "question": question
            ]
        }
    }

    var headers: [String: String]? {
        switch self {
        case .stream:
            var headers = defaultHeaders() ?? [:]
            headers["Accept"] = "text/event-stream"
            headers["Cache-Control"] = "no-cache"
            return headers
        default:
            return defaultHeaders()
        }
    }
}
