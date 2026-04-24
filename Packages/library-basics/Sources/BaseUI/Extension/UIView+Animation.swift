//
//  UIView+Animation.swift
//  LibraryCommon
//
//  Created by Janlor on 6/17/24.
//

import UIKit

public extension AppWrapper where Base: UIView {
    /// 添加呼吸动画
    func addBreathingAnimation(for key: String, minScale: CGFloat, maxScale: CGFloat) {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = minScale
        animation.toValue = maxScale
        animation.duration = 2.0 // 动画持续时间
        animation.autoreverses = true // 动画结束后会自动反转
        animation.repeatCount = Float.infinity // 无限重复
        base.layer.add(animation, forKey: key)
    }
    
    /// 移除呼吸动画
    func removeBreathingAnimation(for key: String) {
        base.layer.removeAnimation(forKey: key)
    }
    
    func addExpansionAnimation(from: CGFloat, to: CGFloat, duration: Double) {
        // 创建扩散动画
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.repeatCount = Float.infinity
        animation.autoreverses = false

        // 创建透明度动画
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0.0
        opacityAnimation.duration = duration
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        opacityAnimation.repeatCount = Float.infinity
        opacityAnimation.autoreverses = false
        
        // 创建动画组并将这两个动画添加到组中
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [animation, opacityAnimation]
        animationGroup.duration = duration  // 设置组的持续时间
        animationGroup.repeatCount = Float.infinity  // 如果需要重复，可以设置这里
        animationGroup.autoreverses = false  // 如果需要反转，可以设置为 true

        // 添加动画到视图的层上
        base.layer.add(animationGroup, forKey: "expansionAndFade")
    }
    
    /// 移除扩散动画
    func removeExpansionAnimation() {
        base.layer.removeAnimation(forKey: "expansionAndFade")
    }
}
