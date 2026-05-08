//
//  GradientDashLineView.swift
//  LibraryBasics
//
//  Created by Janlor on 2025/10/27.
//

import UIKit

/// GradientDashLineView: 渐变色虚线
public final class GradientDashLineView: UIView {
    // MARK: - Public config

    /// 虚线笔触宽度（点）
    public var thickness: CGFloat = 1 {
        didSet { setNeedsLayout() }
    }
    
    /// 虚线中实线段长度（点）
    public var dashLength: CGFloat = 4 {
        didSet { setNeedsLayout() }
    }
    
    /// 虚线间隙长度（点）
    public var gap: CGFloat = 2 {
        didSet { setNeedsLayout() }
    }
    
    /// 渐变颜色数组
    public var colors: [UIColor] = [.gray] {
        didSet { updateGradientColors(); setNeedsLayout() }
    }
    
    /// 渐变起点（0..1 空间），默认水平从左到右
    public var gradientStartPoint: CGPoint = CGPoint(x: 0, y: 0.5) {
        didSet { setNeedsLayout() }
    }
    
    /// 渐变终点（0..1 空间）
    public var gradientEndPoint: CGPoint = CGPoint(x: 1, y: 0.5) {
        didSet { setNeedsLayout() }
    }
    
    /// 横向或纵向（方便外部快速开关），若设置了 isHorizontal，会 override 上面的 start/end
    public var isHorizontal: Bool = true {
        didSet {
            if isHorizontal {
                gradientStartPoint = CGPoint(x: 0, y: 0.5)
                gradientEndPoint = CGPoint(x: 1, y: 0.5)
            } else {
                gradientStartPoint = CGPoint(x: 0.5, y: 0)
                gradientEndPoint = CGPoint(x: 0.5, y: 1)
            }
            setNeedsLayout()
        }
    }
    
    /// 是否隐藏整条线（外面快速开关）
    public override var isHidden: Bool {
        didSet { layer.isHidden = isHidden }
    }

    // MARK: - Private layers

    /// 渐变层（显示）
    private let gradientLayer = CAGradientLayer()
    /// mask 层（用于把渐变裁剪成虚线）
    private let maskShapeLayer = CAShapeLayer()

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        // gradientLayer 基本配置
        gradientLayer.name = "gradientDashGradientLayer"
        gradientLayer.startPoint = gradientStartPoint
        gradientLayer.endPoint = gradientEndPoint
        gradientLayer.masksToBounds = false
        gradientLayer.contentsScale = UIScreen.main.scale

        // maskShapeLayer 基本配置
        maskShapeLayer.name = "gradientDashMaskShapeLayer"
        maskShapeLayer.fillColor = UIColor.clear.cgColor
        maskShapeLayer.strokeColor = UIColor.black.cgColor // 实际颜色由 gradient 提供
        maskShapeLayer.lineCap = .butt
        maskShapeLayer.lineJoin = .round
        maskShapeLayer.contentsScale = UIScreen.main.scale

        // 把 gradientLayer 添加到 view.layer（确保在底部）
        layer.addSublayer(gradientLayer)
        // 将 mask 指向 maskShapeLayer（注意：mask 是 layer 的子层，不显示在 layer.sublayers）
        gradientLayer.mask = maskShapeLayer

        updateGradientColors()
    }

    private func updateGradientColors() {
        gradientLayer.colors = colors.map { $0.cgColor }
    }

    // MARK: - Layout / Path 更新

    public override func layoutSubviews() {
        super.layoutSubviews()

        // 禁用隐式动画，保证 frame/path 同步无动画
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        // gradientLayer 占满整个 view
        gradientLayer.frame = bounds
        gradientLayer.startPoint = gradientStartPoint
        gradientLayer.endPoint = gradientEndPoint

        // maskShapeLayer 也占满（path 使用其 bounds）
        maskShapeLayer.frame = bounds
        maskShapeLayer.lineWidth = thickness
        maskShapeLayer.lineDashPattern = [NSNumber(value: Double(dashLength)), NSNumber(value: Double(gap))]

        // 构建 path：若横向，从左到右的中线；若纵向，从上到下的中线
        let path = UIBezierPath()
        if isHorizontal {
            let y = bounds.midY
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: bounds.width, y: y))
        } else {
            let x = bounds.midX
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: bounds.height))
        }

        maskShapeLayer.path = path.cgPath

        // commit
        CATransaction.commit()
    }

    // MARK: - Public helpers

    /// 用 cgColor array 更新渐变（便于从外部直接传 cgColors）
    public func setColors(_ cgColors: [CGColor]) {
        gradientLayer.colors = cgColors
        setNeedsLayout()
    }

    /// 清理（如果需要从 superview 中移除并重置）
    public func reset() {
        gradientLayer.colors = colors.map { $0.cgColor }
        maskShapeLayer.path = nil
    }
}
