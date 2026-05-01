//
//  NetworkNetworkAuthPlugin.swift
//  LibraryBasics
//
//  Created by Janlor on 5/30/24.
//

import Moya
import Foundation
import Router
import AccountProtocol

class NetworkAuthPlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        // 添加 accessToken 到请求头
        if let token = Router.perform(key: AccountProtocol.self)?.accessToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let orgId = Router.perform(key: AccountProtocol.self)?.orgId,
           request.value(forHTTPHeaderField: "Org-Id") == nil {
            request.setValue("\(orgId)", forHTTPHeaderField: "Org-Id")
        }
        return request
    }
}
