//
//  ResponseModel.swift
//  LibraryCommon
//
//  Created by Janlor on 4/22/26.
//

import Foundation

// 主模型
public struct ResponseModel<T: Codable>: Codable, NetworkRequestable, NetworkCacheable {
    public let msg: String?
    public let code: Int? // 402 过期 需要自动刷 // 401 失效 让用户登录
    public let data: T?
    public let trace: String?
    public let tid: String?
}

public struct EmptyModel: Codable { }
