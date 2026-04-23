//
//  AppForwarder.swift
//  LibraryBasics
//
//  Created by Janlor on 4/22/26.
//

import Foundation
import ObjectiveC

public class AppForwarder: NSObject {
    
    func engine() {
        var methodCount: UInt32 = 0
        guard let methodList = class_copyMethodList(object_getClass(self), &methodCount) else { return }
        
//        print("扫描到 \(methodCount) 个方法")
        
        for i in 0..<Int(methodCount) {
            let method = methodList[i]
            let selector = method_getName(method)
            let selectorName = NSStringFromSelector(selector)
//            print("检查方法: \(selectorName)")
            
            guard selectorName.hasPrefix("app_entry_") else {
//                print("\(selectorName) 不符合前缀要求")
                continue
            }
            
            let argumentCount = method_getNumberOfArguments(method)
//            print("参数总数: \(argumentCount)")
            
            guard argumentCount == 2 else {
//                print("⚠️ 参数数量不符合要求")
//                assertionFailure("方法 [\(selectorName)] 检测到 \(argumentCount - 2) 个参数")
                continue
            }
            
//            print("✅ 调用合规方法: \(selectorName)")
            self.perform(selector)
        }
        
        free(methodList)
    }
    
    // MARK: - 示例方法
//    @objc private func app_entry_example1() {
//        print("执行示例方法 1")
//    }
//    
//    @objc private func app_entry_example2() {
//        print("执行示例方法 2")
//    }
}

// 使用示例
//let forwarder = AppForwarder()
//forwarder.engine()
