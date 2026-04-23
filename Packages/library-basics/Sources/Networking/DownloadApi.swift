//
//  DownloadApi.swift
//  LibraryCommon
//
//  Created by Janlor on 4/22/26.
//

import Foundation
import Moya

public enum DownloadApi: TargetType {
    
    case file(URL, String)
    
    public var baseURL: URL {
        switch self {
        case .file(let url, _):
            return url
        }
    }

    public var path: String {
        switch self {
        default:
            return ""
        }
    }

    public var method: Method {
        return .get
    }

    public var task: Task {
        switch self {
        case .file(_, let fileName):
            return .downloadDestination { temporaryURL, response in
                let fileURL = DownloadApi.destinationPath(fileName)
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
        }
    }

    public var headers: [String: String]? {
        return nil
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public static func destinationPath(_ fileName: String) -> URL {
        return FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
    }
}

