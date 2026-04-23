//
//  UIView+Extension.swift
//  LibraryBasics
//
//  Created by Janlor on 4/22/26.
//

import UIKit

public extension UIView {
    
    // MARK: Shadow

    /// 给 view 添加 四周 阴影
    func appAddShadow(shadowRect: CGRect, shadowRadius: CGFloat, shadowColor: UIColor, shadowOffset: CGSize, shadowOpacity: Float, cornerRadius: CGFloat, clipsCorner: Bool) {
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowOpacity = shadowOpacity
        
        if clipsCorner {
            self.layer.cornerRadius = cornerRadius
            self.clipsToBounds = false
        }
        
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowPath = UIBezierPath(roundedRect: shadowRect, cornerRadius: cornerRadius).cgPath
    }

    /// 同时添加阴影和圆角
    func appAddShadowCorners(rectCorners: UIRectCorner, roundedRect: CGRect, cornerRadii: CGSize, shadowRadius: CGFloat, shadowColor: UIColor, shadowOffset: CGSize, shadowOpacity: Float) {
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowPath = UIBezierPath(roundedRect: roundedRect, byRoundingCorners: rectCorners, cornerRadii: cornerRadii).cgPath
    }

    // MARK: Corners

    /// 使用贝塞尔曲线添加全圆角
    func appAddAllCorners(cornerRadii: CGSize) {
        if #available(iOS 26.0, *), cornerRadii.width == cornerRadii.height, cornerRadii.width > 0 {
            cornerConfiguration = .corners(radius: .fixed(cornerRadii.width))
        } else {
            self.appAddCorners(corners: .allCorners, cornerRadii: cornerRadii)
        }
    }

    /// 使用贝塞尔曲线添加半圆角
    func appAddCorners(corners: UIRectCorner, cornerRadii: CGSize) {
        self.appAddCornersWithRect(rect: self.bounds, corners: corners, cornerRadii: cornerRadii)
    }

    /// 使用贝塞尔曲线添加半圆角
    func appAddCornersWithRect(rect: CGRect, corners: UIRectCorner, cornerRadii: CGSize) {
        let maskPath = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: cornerRadii)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    
    // MARK: - Border & Shadow & Corner
    
    /// 同时设置描边、圆角、阴影
    /// - Parameters:
    ///   - borderWidth: 描边宽度
    ///   - borderColor: 描边颜色
    ///   - cornerRadius: 圆角半径
    ///   - shadowColor: 阴影颜色
    ///   - shadowOpacity: 阴影透明度
    ///   - shadowOffset: 阴影偏移量
    ///   - shadowRadius: 阴影半径
    func appAddStyleView(borderWidth: CGFloat, borderColor: UIColor, cornerRadius: CGFloat, shadowColor: UIColor, shadowOpacity: Float, shadowOffset: CGSize, shadowRadius: CGFloat) {
        
        // 设置圆角
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = false
        
        // 设置描边
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        
        // 设置阴影
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowRadius = shadowRadius
        
        // 为了避免离屏幕渲染，我们可以尝试使用 shadowPath
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
    }

}
