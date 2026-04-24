//
//  UIResponderExtensions.swift
//  LibraryBasics
//
//  Created by Janlor on 2025/4/15.
//

import UIKit

@objc
public extension UIResponder {
    @objc
    var controller: UIViewController? {
        findViewController(from: self)
    }
    
    private func findViewController(from responder: UIResponder) -> UIViewController? {
        
        if case let vc as UIViewController = responder {
            return vc
        }
        
        guard let next = responder.next else {
            return nil
        }
        
        return findViewController(from: next)
    }
}
