//
//  WKWebViewExtensions.swift
//  LibraryBasics
//
//  Created by Janlor on 4/22/26.
//

import Foundation
import WebKit

@objc
public extension WKWebView {
    
    @objc
    /// 在webview中调用js方法
    /// 请在js加载完毕后调用
    /// completionHandler回调始终在主线程中
    func callJs(func name: String, params: [String: Any]?, completionHandler: ((Any?, Error?) -> Void)? = nil ) {
        do {
            let jsString: String
            if let params = params {
                let responseData = try JSONSerialization.data(withJSONObject: params, options: [])
                let jsonStr = String(data: responseData, encoding: .utf8) ?? ""
                jsString = "\(name)" + "(\(jsonStr))"
            } else {
                jsString = "\(name)" + "()"
            }
            
            /// native call js
            evaluateJavaScript(jsString, completionHandler: {
                completionHandler?($0, $1)
            })
        } catch let error {
            assert(false, "[WebViewF]" + "line:\(#line) -- func:[\(#function)] in class:[\(type(of: self))]  --> " + "\(error)")
        }
    }
    
}
