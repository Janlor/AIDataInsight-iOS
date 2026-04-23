//
//  JsIntermediateObj.swift
//  LibraryBasics
//
//  Created by Janlor on 4/22/26.
//

import Foundation

struct JsIntermediateObj {
    
    /// native调用js方法，即callbackId
    let callbackId: String
    
    /// 给js方法的回调
    let callBackClosure: ([String: Any]) -> Void
    
}
