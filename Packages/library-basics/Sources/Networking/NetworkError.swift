//
//  NetworkError.swift
//  LibraryBasics
//
//  Created by Janlor on 2024/11/4.
//

import Foundation
import Alamofire

extension NetworkError {
    public var isTimeout: Bool {
        if case .underlying(let error, _) = self {
            // 尝试将错误转换为 Alamofire.AFError
            if let afError = error as? Alamofire.AFError {
                // 检查是否为 sessionTaskFailed 错误
                if case .sessionTaskFailed(let underlyingError) = afError {
                    // 将 underlyingError 转换为 NSError
                    let nsError = underlyingError as NSError
                    // 检查错误码和域
                    return nsError.code == NSURLErrorTimedOut && nsError.domain == NSURLErrorDomain
                }
            }
            // 也可以直接检查 NSURL错误
            if let urlError = error as? URLError {
                return urlError.code == .timedOut
            }
        }
        return false
    }
}
