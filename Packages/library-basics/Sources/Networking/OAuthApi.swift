//
//  OAuthApi.swift
//  LibraryCommon
//
//  Created by Janlor on 4/22/26.
//

import Foundation

enum OAuthApi: CustomTargetType {
    /// 刷新 Token
    /// refreshToken 刷新令牌
    case refresh(String)
    
    var path: String {
        switch self {
        case .refresh(_):
            return "/oauth2/refresh"
        }
    }
    
    var method: Method {
        switch self {
        case .refresh(_):
            return .get
        }
    }
    
    var parameters: [String : Any] {
        switch self {
        case let .refresh(refreshToken):
            return [
                "refreshToken": refreshToken
            ]
        }
    }
}
