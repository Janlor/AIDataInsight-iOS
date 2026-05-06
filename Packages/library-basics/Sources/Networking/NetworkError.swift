//
//  NetworkError.swift
//  LibraryBasics
//
//  Created by Janlor on 2024/11/4.
//

import Foundation

extension NetworkError {
    public var isTimeout: Bool {
        if case .underlying(let error, _) = self {
            if let urlError = error as? URLError {
                return urlError.code == .timedOut
            }
            let nsError = error as NSError
            return nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorTimedOut
        }
        return false
    }
}
