//
//  JsApiSetAppTitle.swift
//  LibraryBasics
//
//  Created by Janlor on 4/22/26.
//

import Foundation
import WebKit

/// 设置导航栏标题
class JsApiSetAppTitle: JsApiContainer {
    
    var identifier: String {
        "webkit.setAppTitle"
    }
    
    func message(webView: WKWebView?, body data: [String : Any], callBack: (([String : Any]) -> Void)?) {
        if case let title as String = data["data"] {
            webView?.controller?.navigationItem.title = title
        }
    }
    
}

