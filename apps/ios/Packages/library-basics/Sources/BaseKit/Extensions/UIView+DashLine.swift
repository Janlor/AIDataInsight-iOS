//
//  UIView+DashLine.swift
//  LibraryBasics
//
//  Created by Janlor on 2025/10/27.
//

import UIKit

private var kDashLayerKey: UInt8 = 0

public extension UIView {
    private var dashLayer: CAShapeLayer? {
        get { objc_getAssociatedObject(self, &kDashLayerKey) as? CAShapeLayer }
        set { objc_setAssociatedObject(self, &kDashLayerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// 绘制或更新虚线（不会无限制创建新 layer）
    /// - Parameters:
    ///   - thickness: 虚线笔触宽度（点）
    ///   - dashLength: 虚线中实线段长度（点）
    ///   - gap: 虚线间隙长度（点）
    ///   - lineColor: 颜色
    ///   - isHorizontal: 横向或纵向
    func appDrawOrUpdateDashLine(thickness: CGFloat = 1,
                                 dashLength: CGFloat = 4,
                                 gap: CGFloat = 2,
                                 lineColor: UIColor,
                                 isHorizontal: Bool) {
        // reuse or create
        let layer: CAShapeLayer
        if let existing = dashLayer {
            layer = existing
        } else {
            layer = CAShapeLayer()
            layer.name = "appDashLine"
            layer.fillColor = UIColor.clear.cgColor
            layer.lineCap = .butt
            layer.lineJoin = .round
            layer.lineDashPattern = [NSNumber(value: Double(dashLength)), NSNumber(value: Double(gap))]
            self.layer.addSublayer(layer)
            dashLayer = layer
        }
        
        // set common properties
        layer.strokeColor = lineColor.cgColor
        layer.lineWidth = thickness
        layer.contentsScale = UIScreen.main.scale
        layer.needsDisplayOnBoundsChange = true
        
        // frame & path relative to the view's bounds:
        CATransaction.begin()
        CATransaction.setDisableActions(true) // 防止隐式动画
        layer.frame = self.bounds
        
        let path = UIBezierPath()
        if isHorizontal {
            // 中线：y = bounds.midY，从左到右
            let y = bounds.midY
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: bounds.width, y: y))
        } else {
            // 中线：x = bounds.midX，从上到下
            let x = bounds.midX
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: bounds.height))
        }
        layer.path = path.cgPath
        CATransaction.commit()
    }
    
    /// 移除仅名为 "appDashLine" 的 layer（更安全）
    func appRemoveDashLine() {
        guard let layers = self.layer.sublayers else { return }
        for sub in layers.reversed() {
            if let shape = sub as? CAShapeLayer, shape.name == "appDashLine" {
                shape.removeFromSuperlayer()
            }
        }
        dashLayer = nil
    }
}
