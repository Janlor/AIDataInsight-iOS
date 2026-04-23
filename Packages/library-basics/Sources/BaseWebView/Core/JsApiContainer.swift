//
//  JsApiContainer.swift
//  LibraryBasics
//
//  Created by Janlor on 4/22/26.
//

import Foundation
import WebKit

@objc(AppJsApiContainer)
public protocol JsApiContainer: AnyObject {
    
    @objc
    /// api名称
    var identifier: String { get }
    
    @objc
    /// 来自webview的js调用
    func message(webView: WKWebView?, body data: [String: Any], callBack: (([String: Any]) -> Void)?)
}
