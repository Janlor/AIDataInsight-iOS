//
//  RouterServiceStore.swift
//  LibraryBasics
//
//  Created by Janlor on 2024/5/22.
//

import Foundation
import UIKit

class RouterServiceStore {
    init() {}

    /// 注册协议和业务路由
    func register<Protocol, T>(key: Protocol.Type, module object: T) where T: RouterDestination {
        businessRouters[String(describing: key)] = object
    }

    func register<Protocol, T>(key: Protocol.Type, module class: T.Type) where T: RouterDestination & RouterService {
        businessRouterClasses[String(describing: key)] = `class`
    }

    /// 查找业务路由
    func find<Protocol>(key: Protocol.Type) -> Protocol? {
        let router = businessRouters[String(describing: key)]
        guard router == nil else {
            return router as? Protocol
        }

        let `class` = businessRouterClasses[String(describing: key)]
        if let cls = (`class` as? RouterService.Type) {
            return cls.init() as? Protocol
        }

        return nil
    }

    /// 业务路由对象集合
    var businessRouters: [String: Any] = [:]

    /// 业务路由类型集合
    var businessRouterClasses: [String: Any] = [:]
}
