//
//  DownloadApi.swift
//  LibraryBasics
//
//  Created by Janlor on 6/13/24.
//

import Foundation

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
