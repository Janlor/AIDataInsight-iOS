//
//  ResponseError.swift
//  Network
//
//  Created by Janlor on 4/22/26.
//

import Foundation
import Moya
import Alamofire

public enum ResponseError: Swift.Error {
    /// 未知错误
    case unknown
    ///  数据格式错误
    ///  非[String: Any]
    case dataFormat(Any)
    
    case server(Int?, String?)
}

extension ResponseError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unknown:
            return NSLocalizedString("未知错误", bundle: .module, comment: "")
        case .dataFormat:
            return "数据格式错误, 非[String: Any]"
        case .server(_, let msg):
            return msg
        }
    }
}

extension ResponseError: CustomNSError {
    public var errorUserInfo: [String: Any] {
        switch self {
        case .unknown:
            return [:]
        case .dataFormat(let any):
            return ["userInfo": any]
        case .server(let code, let msg):
            return [
                "code": code ?? 0,
                "msg": msg ?? ""]
        }
    }
}

extension MoyaError {
    public var localizedDescription: String {
        switch self {
        case .imageMapping:
            return NSLocalizedString("Failed to map data to an Image.", bundle: .module, comment: "")
        case .jsonMapping:
            return NSLocalizedString("Failed to map data to JSON.", bundle: .module, comment: "")
        case .stringMapping:
            return NSLocalizedString("Failed to map data to a String.", bundle: .module, comment: "")
        case .objectMapping:
            return NSLocalizedString("Failed to map data to a Decodable object.", bundle: .module, comment: "")
        case .encodableMapping:
            return NSLocalizedString("Failed to encode Encodable object into data.", bundle: .module, comment: "")
        case .statusCode(let response):
            let code = response.statusCode
            return String(format: NSLocalizedString("Status code %d didn't fall within the given range.", bundle: .module, comment: ""), code) 
        case .underlying(let error, _):
            if case let .sessionTaskFailed(innerError) = error as? AFError,
               let nsError = innerError as NSError?,
               let errorMessage = nsError.userInfo[NSLocalizedDescriptionKey] as? String {
                return errorMessage
            }
            return error.localizedDescription
        case .requestMapping:
            return NSLocalizedString("Failed to map Endpoint to a URLRequest.", bundle: .module, comment: "")
        case .parameterEncoding(let error):
            return String(format: NSLocalizedString("Failed to encode parameters for URLRequest. %@", bundle: .module, comment: ""), error.localizedDescription)
        }
    }
}
