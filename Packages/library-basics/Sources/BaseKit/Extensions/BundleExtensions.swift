//
//  BundleExtensions.swift
//  LibraryBasics
//
//  Created by Janlor on 4/22/26.
//

import Foundation

extension Bundle {
    
    /// 获取当前组件的Bundle
    /// - Parameters:
    ///   - currentName: 组件名
    ///   - temp: 组件内的任意类
    /// - Returns: Bundle
    public class func currentBundle(currentName:String,temp:AnyClass) -> Bundle? {
        return Bundle.appBundle(withBundleName: currentName, targetClass: temp)
    }
    
}

extension Bundle {
    class func appBundle(withBundleName bundleName: String?, targetClass: AnyClass) -> Self {
        //并没有拿到子bundle
        //let bundle = Bundle(for: type(of: targetClass))
        let bundle = Bundle(for: targetClass)
        //在这个路径下找到子bundle的路径
        let path = bundle.path(forResource: bundleName, ofType: "bundle")
        //根据路径拿到子bundle
        if let path = path {
            return Bundle(path: path)! as! Self
        }
        return self.appBundle(bundleName: bundleName)
    }
    
    class func appBundle(bundleName:String?) -> Self {
        let mainBundle = Bundle.main
        var path = mainBundle.path(forResource: bundleName, ofType: "bundle")
        if path == nil {
            let tempPath = "Frameworks/" + (bundleName ?? "") + ".framework/" + (bundleName ?? "")
            path = mainBundle.path(forResource: tempPath, ofType: "bundle")
        }
        let bundle:Bundle = Bundle(path: path ?? "") ?? Bundle.main
        return bundle as! Self
    }
}

