//
//  DashLineView.swift
//  LibraryBasics
//
//  Created by Janlor on 4/22/26.
//

import UIKit

// DashLineView: 绘制或更新虚线
public final class DashLineView: UIView {
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
    
    /// 颜色
    public var lineColor: UIColor = .gray {
        didSet { dashLayer.strokeColor = lineColor.cgColor }
    }
    
    /// 横向或纵向
    public var isHorizontal: Bool = false {
        didSet { setNeedsLayout() }
    }
    
    /// 持有并更新 CAShapeLayer
    private let dashLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
        commonInit()
    }
    
    private func commonInit() {
        dashLayer.name = "dashLayer"
        dashLayer.fillColor = UIColor.clear.cgColor
        dashLayer.contentsScale = UIScreen.main.scale
        dashLayer.lineCap = .butt
        dashLayer.lineJoin = .round
        layer.addSublayer(dashLayer)
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard let previousTraitCollection = previousTraitCollection else { return }
        if (previousTraitCollection.hasDifferentColorAppearance(comparedTo: traitCollection)) {
            dashLayer.strokeColor = lineColor.cgColor
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        dashLayer.frame = bounds
        dashLayer.lineWidth = thickness
        dashLayer.lineDashPattern = [NSNumber(value: Double(dashLength)), NSNumber(value: Double(gap))]
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
        dashLayer.path = path.cgPath
        dashLayer.strokeColor = lineColor.cgColor
        CATransaction.commit()
    }
}
