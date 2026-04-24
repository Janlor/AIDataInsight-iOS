//
//  WKWebViewConfigurationExtensions.swift
//  LibraryBasics
//
//  Created by Janlor on 2025/4/15.
//

import Foundation
import WebKit

public extension WKWebViewConfiguration {
    
    @objc
    /// 注入脚本
    /// 如果不用组件提供的WKWebViewController，则在自己的WKWebViewController的viewwillappear中添加
    /// 与removeJsbridge成对出现
    func addJsBridge() {
        JsApiManager.manager.addJsBridge(into: self)
    }
    
    @objc
    /// 移出脚本
    /// 如果不用组件提供的WKWebViewController，则在自己的WKWebViewController的viewwilldisappear中移出
    /// 与addJsBridge成对出现
    func removeJsbridge() {
        JsApiManager.manager.removeJsbridge(from: self)
    }
    
}
