//
//  UIView+Frame.swift
//  LibraryCommon
//
//  Created by Janlor on 6/18/24.
//

import UIKit

public extension UIView {
//    var x: CGFloat {
//        get {
//            return self.frame.origin.x
//        }
//        set {
//            var frame = self.frame
//            frame.origin.x = newValue
//            self.frame = frame
//        }
//    }
    
//    var y: CGFloat {
//        get {
//            return self.frame.origin.y
//        }
//        set {
//            var frame = self.frame
//            frame.origin.y = newValue
//            self.frame = frame
//        }
//    }
    
//    var width: CGFloat {
//        get {
//            return self.frame.size.width
//        }
//        set {
//            var frame = self.frame
//            frame.size.width = newValue
//            self.frame = frame
//        }
//    }
    
//    var height: CGFloat {
//        get {
//            return self.frame.size.height
//        }
//        set {
//            var frame = self.frame
//            frame.size.height = newValue
//            self.frame = frame
//        }
//    }
    
    var origin: CGPoint {
        get {
            return self.frame.origin
        }
        set {
            var frame = self.frame
            frame.origin = newValue
            self.frame = frame
        }
    }
    
//    var size: CGSize {
//        get {
//            return self.frame.size
//        }
//        set {
//            var frame = self.frame
//            frame.size = newValue
//            self.frame = frame
//        }
//    }
    
    var centerX: CGFloat {
        get {
            return self.center.x
        }
        set {
            var center = self.center
            center.x = newValue
            self.center = center
        }
    }
    
    var centerY: CGFloat {
        get {
            return self.center.y
        }
        set {
            var center = self.center
            center.y = newValue
            self.center = center
        }
    }
    
    var left: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }
    
    var top: CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }
    
    var right: CGFloat {
        get {
            return self.frame.origin.x + self.frame.size.width
        }
        set {
            var frame = self.frame
            frame.origin.x = newValue - frame.size.width
            self.frame = frame
        }
    }
    
    var bottom: CGFloat {
        get {
            return self.frame.origin.y + self.frame.size.height
        }
        set {
            var frame = self.frame
            frame.origin.y = newValue - frame.size.height
            self.frame = frame
        }
    }
}
