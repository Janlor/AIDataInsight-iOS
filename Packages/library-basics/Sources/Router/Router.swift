//
//  Router.swift
//  LibraryBasics
//
//  Created by Janlor on 2024/5/22.
//

import Foundation
import UIKit

/// 注册业务路由类型时需要实现的协议
public protocol RouterService {
    init()
}

/// 创建业务路由对象，提供路由服务的一方需要实现
public protocol RouterDestination {
    /// 可选闭包就是隐式的逃逸闭包
    func to(_ arg: [AnyHashable: Any]?,
            _ closure: ((_ event: Any, _ arg: [AnyHashable: Any]?) -> Void)?) -> UIViewController
}

public extension RouterDestination {
    func to(_ arg: [AnyHashable: Any]?,
            _ closure: ((_ event: Any, _ arg: [AnyHashable: Any]?) -> Void)?) -> UIViewController {
        UIViewController()
    }
}

public struct Router {

    /// 单例
    static let handler = Router()

    /// 业务路由集合
    let store = RouterServiceStore.init()

    /// 通过公开的协议查找业务路由
    func find<Protocol>(key: Protocol.Type) -> Protocol? {
        store.find(key: key)
    }

}

public extension Router {
    /// 注册业务路由实例，业务路由为常驻状态
    /// T需要实现Protocol协议
    static func register<Protocol, T>(key: Protocol.Type, module object: T) where T: RouterDestination {
        Router.handler.store.register(key: key, module: object)
    }

    /// 注册业务路由类型，在具体调用时进行实例化，使用完毕即不再持有
    /// T需要实现Protocol协议
    static func register<Protocol, T>(key: Protocol.Type,
                                      module class: T.Type) where T: RouterDestination & RouterService {
        Router.handler.store.register(key: key, module: `class`)
    }
}

public extension Router {
    /// key 为业务路由提供功能的协议类型
    static func perform<Protocol>(key: Protocol.Type) -> Protocol? {
        Router.handler.find(key: key)
    }
}

public extension Router {

    static func target<Protocol>(to key: Protocol.Type) -> UIViewController? {
        guard let routerService = Router.handler.find(key: key) as? RouterDestination  else {
            return nil
        }
        return routerService.to(nil, nil)
    }

    @discardableResult
    static func push<Protocol>(from viewController: UIViewController,
                               to key: Protocol.Type, animated: Bool) -> Eventable? {
        guard let routerService = Router.handler.find(key: key) as? RouterDestination  else {
            return nil
        }
        return Behavior { behavior in
            viewController.navigationController?
                .pushViewController(routerService.to(behavior.params, behavior.eventHandler), animated: animated)
        }
    }

    @discardableResult
    static func present<Protocol>(from viewController: UIViewController,
                                  to key: Protocol.Type, animated: Bool,
                                  completion: (() -> Void)? = nil) -> Eventable? {
        guard let routerService = Router.handler.find(key: key) as? RouterDestination else {
            return nil
        }
        return Behavior { behavior in
            viewController.present(routerService.to(behavior.params, behavior.eventHandler),
                         animated: animated, completion: completion)
        }
    }

    @discardableResult
    /// 调用方自定义动画，请在闭包中自定义跳转动画
    static func show<Protocol>(from viewController: UIViewController,
                               to key: Protocol.Type,
                               closure: @escaping (_ from: UIViewController,
                                                   _ to: UIViewController) -> Void) -> Eventable? {
        guard let routerService = Router.handler.find(key: key) as? RouterDestination else {
            return nil
        }
        return Behavior { behavior in
            closure(viewController, routerService.to(behavior.params, behavior.eventHandler))
        }
    }
}

public protocol Eventable {
    @discardableResult
    /// 简单的事件回调，同步和异步调用均可
    func eventHandler(_ closure:
                      @escaping (_ event: Any, _ arg: [AnyHashable: Any]?) -> Void) -> Eventable

    @discardableResult
    /// 传参
    func insert(params: [AnyHashable: Any]) -> Eventable
}

private class Behavior: Eventable {

    var params: [AnyHashable: Any]?
    var action: ((_ behavior: Behavior) -> Void)?
    var eventHandler: ((_ event: Any, _ arg: [AnyHashable: Any]?) -> Void)?

    init(action: @escaping (_ behavior: Behavior) -> Void) {
        self.action = action
    }

    func eventHandler(_ closure: @escaping (Any, [AnyHashable: Any]?) -> Void) -> Eventable {
        eventHandler = closure
        return self
    }

    func insert(params: [AnyHashable: Any]) -> Eventable {
        self.params = params
        return self
    }

    deinit {
        action?(self)
        do {
            params = nil
            action = nil
            eventHandler = nil
        }
    }
}
