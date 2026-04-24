//
//  JsApiCallPhone.swift
//  LibraryBasics
//
//  Created by Janlor on 2025/4/15.
//

import Foundation
import WebKit

/// 拨打电话
class JsApiCallPhone: JsApiContainer {
    var identifier: String {
        "webkit.callPhone"
    }
    
    func message(webView: WKWebView?, body data: [String : Any], callBack: (([String : Any]) -> Void)?) {
        let phone = data["data"] as? String
        
        guard let phone = phone else {
            return
        }
        
        // phoneStr:  电话号码
        let phoneUriStr = "telprompt://" + phone
        let phoneUri = URL(string: phoneUriStr)
        
        guard let phoneUri = phoneUri else {
            return
        }
        
        if UIApplication.shared.canOpenURL(phoneUri) {
            UIApplication.shared.open(phoneUri)
        }
    }
    
}
