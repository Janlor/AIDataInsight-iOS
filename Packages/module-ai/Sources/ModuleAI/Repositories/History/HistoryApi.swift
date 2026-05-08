//
//  HistoryApi.swift
//  ModuleAI
//
//  Created by Janlor on 2024/10/29.
//

import Foundation
import Networking

enum HistoryApi: RequestDescriptor {
    /// 查询历史会话列表
    case page(Int, Int)
    /// 查询历史会话详情
    case detail(Int)
    /// 更新历史详情是否喜欢
    case like(Int, String)
    /// 删除历史会话
    case delete(Int)
    /// 清空所有历史会话
    case deleteAll
    
    var path: String {
        switch self {
        case .page(_,_):
            return "/history/page"
        case .detail(_):
            return "/history/detail"
        case .like(_,_):
            return "/history/like"
        case .delete(_):
            return "/history/delete"
        case .deleteAll:
            return "/history/deleteAll"
        }
    }
    
    var method: Networking.Method {
        switch self {
        case .page(_,_):
            return .get
        case .detail(_):
            return .get
        case .like(_,_):
            return .post
        case .delete(_):
            return .get
        case .deleteAll:
            return .get
        }
    }
    
    var parameters: [String : Any] {
        switch self {
        case .page(let currentPage, let pageSize):
            return [
                "currentPage": currentPage,
                "pageSize": pageSize
            ]
        case .detail(let historyId):
            return [
                "historyId": historyId
            ]
        case .like(let historyDetailId, let like):
            return [
                "historyDetailId": historyDetailId,
                "like": like
            ]
        case .delete(let historyId):
            return [
                "historyId": historyId
            ]
        case .deleteAll:
            return [:]
        }
    }
}
