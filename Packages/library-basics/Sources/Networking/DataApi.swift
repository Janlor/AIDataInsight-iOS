//
//  DataApi.swift
//  LibraryBasics
//
//  Created by Janlor on 11/28/25.
//

import Foundation

public enum DataApi: TargetType {
    /// 审批详情打印
    case batchPrint([String], String)

    public var baseURL: URL {
        switch self {
        case .batchPrint(_,_):
            return NetworkServer.baseURL
        }
    }

    public var path: String {
        switch self {
        case .batchPrint(_,_):
            return "/examine/instance/batchPrint"
        default:
            return ""
        }
    }

    public var method: Method {
        return .post
    }

    public var task: Task {
        switch self {
        case .batchPrint(let instanceList, _):
            let body = (try? JSONEncoder().encode(instanceList)) ?? Data()
            return .requestData(body)
        }
    }

    public var headers: [String : String]? {
        return [
            "Content-Type": "application/json",
            "Accept": "application/pdf"
        ]
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public static func destinationPath(_ fileName: String) -> URL {
        return FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
    }
}
