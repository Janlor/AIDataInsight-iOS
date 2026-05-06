//
//  MenuBackgroundView.swift
//  ModuleAI
//
//  Created by Janlor on 2024/10/29.
//

import UIKit
import BaseUI

class MenuBackgroundView: UIPopoverBackgroundView {
    // 必须实现的属性
    private var arrowOffset_: CGFloat = 0.0
    private var arrowDirection_: UIPopoverArrowDirection = .any
    
    // 背景视图
    private var backgroundView: UIView = {
        let view = UIView()
        let trait = UITraitCollection(userInterfaceStyle: .light)
        view.backgroundColor = UIColor.theme.secondaryLabel.resolvedColor(with: trait)
        view.applyCapsule(.medium)
        return view
    }()
    
    // 必须实现的类方法
    override class func contentViewInsets() -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    override class func arrowHeight() -> CGFloat {
        return 6 // 箭头高度
    }
    
    override class func arrowBase() -> CGFloat {
        return 12 // 箭头底部宽度
    }
    
    // 必须实现的实例方法
    override var arrowDirection: UIPopoverArrowDirection {
        get { return arrowDirection_ }
        set { arrowDirection_ = newValue }
    }
    
    override var arrowOffset: CGFloat {
        get { return arrowOffset_ }
        set { arrowOffset_ = newValue }
    }
    
    // 初始化方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(backgroundView)
        backgroundView.alpha = 0 // 初始设置为透明
    }
    
    // 布局子视图
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 如果是首次布局，添加动画
        if backgroundView.alpha == 0 {
            // 添加缩放动画
            backgroundView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            UIView.animate(
                withDuration: 0.10,
                delay: 0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 0.1,
                options: .curveEaseOut
            ) {
                self.backgroundView.transform = .identity
                self.backgroundView.alpha = 1
            }
        }
        
        let arrowHeight = Self.arrowHeight()
        let arrowBase = Self.arrowBase()
        let cornerRadius: CGFloat = 8
        
        // 根据箭头方向设置内边距
        let rect = bounds.inset(by: UIEdgeInsets(
            top: arrowDirection == .down ? 0 : (arrowDirection == .up ? arrowHeight : 0),
            left: arrowDirection == .right ? 0 : (arrowDirection == .left ? arrowHeight : 0),
            bottom: arrowDirection == .up ? 0 : (arrowDirection == .down ? arrowHeight : 0),
            right: arrowDirection == .left ? 0 : (arrowDirection == .right ? arrowHeight : 0)
        ))
        
        // 创建完整的路径
        let path = UIBezierPath()
        
        switch arrowDirection {
        case .up:
            // 上箭头
            let arrowX = bounds.width/2 + arrowOffset
            path.move(to: CGPoint(x: arrowX - arrowBase/2, y: arrowHeight))
            path.addLine(to: CGPoint(x: arrowX, y: 0))
            path.addLine(to: CGPoint(x: arrowX + arrowBase/2, y: arrowHeight))
            addRoundedRect(to: path, rect: rect, startingFromArrowSide: true)
            
        case .down:
            // 下箭头
            path.move(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY))
            addRoundedRect(to: path, rect: rect, startingFromArrowSide: false)
            let arrowX = bounds.width/2 + arrowOffset
            path.addLine(to: CGPoint(x: arrowX + arrowBase/2, y: rect.maxY))
            path.addLine(to: CGPoint(x: arrowX, y: bounds.height))
            path.addLine(to: CGPoint(x: arrowX - arrowBase/2, y: rect.maxY))
            
        case .left:
            // 从左上角开始，按顺时针方向绘制
            path.move(to: CGPoint(x: arrowHeight, y: rect.minY + cornerRadius))
            
            // 上边
            path.addArc(withCenter: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
                       radius: cornerRadius,
                       startAngle: CGFloat.pi,
                       endAngle: -CGFloat.pi/2,
                       clockwise: true)
            path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
            
            // 右上角
            path.addArc(withCenter: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
                       radius: cornerRadius,
                       startAngle: -CGFloat.pi/2,
                       endAngle: 0,
                       clockwise: true)
            
            // 右边
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
            
            // 右下角
            path.addArc(withCenter: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
                       radius: cornerRadius,
                       startAngle: 0,
                       endAngle: CGFloat.pi/2,
                       clockwise: true)
            
            // 下边
            path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
            
            // 左下角
            path.addArc(withCenter: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius),
                       radius: cornerRadius,
                       startAngle: CGFloat.pi/2,
                       endAngle: CGFloat.pi,
                       clockwise: true)
            
            // 绘制箭头
            let arrowY = bounds.height/2 + arrowOffset
            path.addLine(to: CGPoint(x: arrowHeight, y: arrowY + arrowBase/2))
            path.addLine(to: CGPoint(x: 0, y: arrowY))
            path.addLine(to: CGPoint(x: arrowHeight, y: arrowY - arrowBase/2))
            
            // 连回起点
            path.addLine(to: CGPoint(x: arrowHeight, y: rect.minY + cornerRadius))
            
        case .right:
            // 右箭头
            path.move(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY))
            addRoundedRect(to: path, rect: rect, startingFromArrowSide: false)
            let arrowY = bounds.height/2 + arrowOffset
            path.addLine(to: CGPoint(x: rect.maxX, y: arrowY - arrowBase/2))
            path.addLine(to: CGPoint(x: bounds.width, y: arrowY))
            path.addLine(to: CGPoint(x: rect.maxX, y: arrowY + arrowBase/2))
            
        default:
            // 如果没有箭头，就只绘制圆角矩形
            addRoundedRect(to: path, rect: bounds, startingFromArrowSide: false)
        }
        
        path.close()
        
        // 应用路径
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.black.cgColor
        backgroundView.layer.mask = shapeLayer
        backgroundView.frame = bounds
    }
    
    // 辅助方法：添加圆角矩形路径
    private func addRoundedRect(to path: UIBezierPath, rect: CGRect, startingFromArrowSide: Bool) {
        let cornerRadius: CGFloat = 8
        
        if !startingFromArrowSide {
            path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        }
        
        // 右上角
        path.addArc(withCenter: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
                    radius: cornerRadius,
                    startAngle: -CGFloat.pi/2,
                    endAngle: 0,
                    clockwise: true)
        
        // 右边
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
        
        // 右下角
        path.addArc(withCenter: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
                    radius: cornerRadius,
                    startAngle: 0,
                    endAngle: CGFloat.pi/2,
                    clockwise: true)
        
        // 底边
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
        
        // 左下角
        path.addArc(withCenter: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius),
                    radius: cornerRadius,
                    startAngle: CGFloat.pi/2,
                    endAngle: CGFloat.pi,
                    clockwise: true)
        
        // 左边
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        
        // 左上角
        path.addArc(withCenter: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
                    radius: cornerRadius,
                    startAngle: CGFloat.pi,
                    endAngle: -CGFloat.pi/2,
                    clockwise: true)
        
        if startingFromArrowSide {
            path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        }
    }
    
    // 添加消失动画
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        // 当视图从窗口移除时（popover消失）
        if window == nil {
            UIView.animate(
                withDuration: 0.1,
                delay: 0,
                options: .curveEaseIn,
                animations: {
                    self.backgroundView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    self.backgroundView.alpha = 0
                }
            )
        }
    }
} 
