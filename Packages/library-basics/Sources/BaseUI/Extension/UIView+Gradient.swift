//
//  UIView+Gradient.swift
//  LibraryCommon
//
//  Created by Janlor on 5/29/24.
//

import UIKit

public extension AppWrapper where Base: UIView {
    /// 生成渐变色图层
    /// - Parameters:
    ///   - colors: 颜色
    ///   - locations: 位置
    ///   - startPoint: 起点
    ///   - endPoint: 终点
    ///   - opacity: 透明度
    /// - Returns: 渐变色图层
    func gradientLayer(colors: [UIColor],
                       locations: [NSNumber],
                       frame: CGRect? = nil,
                       startPoint: CGPoint = CGPoint(x: 0, y: 0),
                       endPoint: CGPoint = CGPoint(x: 1, y: 1),
                       opacity: Float = 1) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.compactMap { $0.cgColor }
        gradientLayer.locations = locations
        gradientLayer.frame = frame ?? base.bounds
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.opacity = opacity
        return gradientLayer
    }
}
