//
//  LoginProtocol.swift
//  Protocol
//
//  Created by Janlor on 2024/5/22.
//

import Foundation

public protocol CancellableTask {
    var isCancelled: Bool { get }
    func cancel()
}

public protocol LoginProtocol {
    typealias BoolResultClosure = (Bool, String?) -> Void
    
    /// 刷新 token
    @discardableResult
    func refresh(_ token: String, _ reslut: @escaping BoolResultClosure) -> CancellableTask
    
    /// 刷新 token，async 版本
    func refresh(_ token: String) async throws
    
    /// 退出登录
    func logout(_ reslut: @escaping BoolResultClosure)
    
    /// 退出登录，async 版本
    func logout() async throws
}
