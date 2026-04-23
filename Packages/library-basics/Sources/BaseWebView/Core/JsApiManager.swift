//
//  JsApiManager.swift
//  LibraryBasics
//
//  Created by Janlor on 4/22/26.
//

import Foundation
import WebKit

@objc(AppJsApiManager)
public class JsApiManager: NSObject {
    
    @objc
    /// 单例
    public static let manager = JsApiManager()
    
    private override init() {
        super.init()
        /// 添加默认jsapi
        self.addDefalutJsApi([
            JsApiSetAppTitle(),
            JsApiCallPhone(),
        ])
    }
    
    private var _addedJsApiHashMap: [String: JsApiContainer] = [:]

    private var _defalutJsHashMap: [String: JsApiContainer] = [:]
    
    @objc
    /// 是否允许加载默认jsapi， 默认true
    public var allowLoadDefalutJsBridge: Bool = true
    
    @objc
    /// 是否允加载许开发者的jsapi，默认true
    public var allowLoadUserJsBridge: Bool = true
    
    // MARK: 埋点相关业务
    @objc
    public var scriptMessageHandler: WKScriptMessageHandler {
        self
    }
    
    @objc
    public var userContentControllerClosure: ((WKUserContentController, WKScriptMessage) -> Void)?
}

public extension JsApiManager {
    
    @objc
    /// 开发者添加的jsApi
    var addedJsApis: [String: JsApiContainer] {
        _addedJsApiHashMap
    }
    
    @objc
    /// 默认配置的jsApi
    var defalutJsApis: [String: JsApiContainer] {
        _defalutJsHashMap
    }
    
    @objc
    /// 添加js api
    func addJsApi(_ list: [JsApiContainer]) {
        for item in list {
            for key in _addedJsApiHashMap.keys {
                if key == item.identifier {
                    assert(false, "line\(#line): \(#function) in \(type(of: self))," + "identifier=\(key)不能重复添加，" + "请移除")
                    return
                }
            }
            _addedJsApiHashMap[item.identifier] = item
        }
    }
    
    @objc
    /// 移出js api
    func removeJsApi(_ list: [JsApiContainer] ) {
        for item in list {
            _addedJsApiHashMap[item.identifier] = nil
        }
    }
    
    /// 添加默认js api
    private func addDefalutJsApi(_ list: [JsApiContainer]) {
        for item in list {
            for key in _defalutJsHashMap.keys {
                if key == item.identifier {
                    assert(false, "line\(#line): \(#function) in \(type(of: self))," + "identifier=\(key)不能重复添加，" + "请移除")
                    return
                }
            }
            _defalutJsHashMap[item.identifier] = item
        }
    }
    
    /// 移出默认js api
    private func removeDefalutJsApi(_ list: [JsApiContainer] ) {
        for item in list {
            _defalutJsHashMap[item.identifier] = nil
        }
    }

}

public extension JsApiManager {
    
    @objc
    /// 注入脚本
    /// 如果不用组件提供的WKWebViewController，则在自己的WKWebViewController的viewwillappear中添加
    /// 与removeJsbridge(from:)成对出现
    func addJsBridge(into config: WKWebViewConfiguration) {
        DispatchQueue.main.async {
            self._addedJsApiHashMap.keys.forEach { key in
                config.userContentController.add(self, name: key)
            }
            self._defalutJsHashMap.keys.forEach { key in
                config.userContentController.add(self, name: key)
            }
        }
    }
    
    @objc
    /// 移出脚本
    /// 如果不用组件提供的WKWebViewController，则在自己的WKWebViewController的viewwilldisappear中移出
    /// 与addJsBridge(into:)成对出现
    func removeJsbridge(from config: WKWebViewConfiguration)  {
        DispatchQueue.main.async {
            self._addedJsApiHashMap.keys.forEach { key in
                config.userContentController.removeScriptMessageHandler(forName: key)
            }
            self._defalutJsHashMap.keys.forEach { key in
                config.userContentController.removeScriptMessageHandler(forName: key)
            }
        }
    }
}

extension JsApiManager: WKScriptMessageHandler {
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        /// 埋点
        self.userContentControllerClosure?(userContentController, message)
        
        debugPrint("[WebViewF]" + "line:\(#line) -- func:[\(#function)] in class:[\(type(of: self))] --> " + "message.name = \(message.name)" + " --> " + "message.body = \(message.body)")
        do {
            let key = message.name
            let body = try (message.body as? String)?.toDictionary() ?? [:]
            
            let obj = createJsIntermediateObj(callbackId: body["callbackId"] as? String, webView: message.webView)
            
            // 如果addedJsApis中注册了defalutJsApis中重复的JsApiContainer，则只执行addedJsApis中的JsApiContainer
            if allowLoadUserJsBridge, let jsapi = addedJsApis[key] {
                jsapi.message(webView: message.webView, body: body, callBack: obj?.callBackClosure)
                return
            }
            
            if allowLoadDefalutJsBridge, let jsapi = defalutJsApis[key] {
                jsapi.message(webView: message.webView, body: body, callBack: obj?.callBackClosure)
                return
            }
            
        } catch let error {
            assert(false, "[WebViewF]" + "line:\(#line) -- func:[\(#function)] in class:[\(type(of: self))] --> " + "\(error)")
        }
    }
    
    private func createJsIntermediateObj(callbackId: String?, webView: WKWebView?) -> JsIntermediateObj? {
        guard let callbackId = callbackId, let webView = webView else {
            return nil
        }

        return JsIntermediateObj(callbackId: callbackId) { [weak webView] data in
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                    print("Failed to encode JSON string")
                    return
                }

                // 构建完整的 JS 调用（此处传的是 JS 对象字符串，避免拼接）
                let jsCode = "JsBridge.handleMessageFromNative(\(jsonString));"

                DispatchQueue.main.async {
                    webView?.evaluateJavaScript(jsCode) { _, error in
                        if let error = error {
                            print("JS 调用失败：\(error)")
                        }
                    }
                }

            } catch {
                print("JSON 序列化失败: \(error)")
            }
        }
    }
}
