//
//  CustomMultiTarget.swift
//  Network
//
//  Created by Janlor on 4/22/26.
//

import Foundation
import Moya

public enum CustomMultiTarget: Moya.TargetType {

    case target(CustomTargetType)
    
    private var target: CustomTargetType {
        switch self {
            case .target(let target): return target
        }
    }
    
    init(_ target: CustomTargetType) {
        self = CustomMultiTarget.target(target)
    }
    
    public var baseURL: URL {
        target.baseURL
    }
    
    public var path: String {
        target.path
    }
    
    public var method: Moya.Method {
        target.method
    }
    
    public var sampleData: Data {
        target.sampleData
    }
    
    /// The type of HTTP task to be performed.
    public var task: Task {
        target.task
    }
    
    /// The headers to be used in the request.
    public var headers: [String: String]? {
        target.headers
    }

}
