//
//  UIView+Shake.swift
//  LibraryBasics
//
//  Created by Janlor on 4/22/26.
//

import UIKit

public enum ShakeDirection {
    case horizontal
    case vertical
}

public extension UIView {
    
    /// 默认抖动效果
    func defaultShakeAnimation() {
        shakeAnimation(direction: .horizontal, times: 2, interval: 0.25, delta: 8)
    }
    
    /// 开始抖动动画
    /// - Parameters:
    ///   - direction: 抖动方向
    ///   - times: 抖动次数
    ///   - interval: 单次抖动时间
    ///   - delta: 抖动偏移量
    ///   - completion: 结束后的回调
    func shakeAnimation(direction: ShakeDirection, times: Int, interval: TimeInterval, delta: CGFloat, completion: ((Bool) -> Void)? = nil) {
        let animation = CAKeyframeAnimation(keyPath: direction == .horizontal ? "transform.translation.x" : "transform.translation.y")
        animation.values = [0, delta, 0]
        animation.repeatCount = Float(times)
        animation.duration = interval
        animation.isRemovedOnCompletion = true
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?(true)
        }
        self.layer.add(animation, forKey: direction == .horizontal ? "shakeX" : "shakeY")
        CATransaction.commit()
    }
}
