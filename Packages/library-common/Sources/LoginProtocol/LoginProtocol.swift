//
//  LoginProtocol.swift
//  Protocol
//
//  Created by Janlor on 2024/5/22.
//

import UIKit
import AccountProtocol

public protocol CancellableTask {
    var isCancelled: Bool { get }
    func cancel()
}

public protocol LoginProtocol {
    typealias BoolResultClosure = (Bool, String?) -> Void
    
    /// 刷新 token
    @discardableResult
    func refresh(_ token: String, _ reslut: @escaping BoolResultClosure) -> CancellableTask
    
    /// 退出登录
    func logout(_ reslut: @escaping BoolResultClosure)
}
