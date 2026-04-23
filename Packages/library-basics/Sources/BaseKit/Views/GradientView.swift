//
//  GradientView.swift
//  LibraryBasics
//
//  Created by Janlor on 4/22/26.
//

import UIKit

/// 通用渐变背景视图，可水平、垂直或自定义方向渐变。
public final class GradientView: UIView {
    
    /// 渐变颜色（至少两个）
    public var colors: [UIColor] = [.white, .black] {
        didSet { updateGradient() }
    }
    
    /// 渐变位置（0~1），可选
    public var locations: [NSNumber]? {
        didSet { gradientLayer.locations = locations }
    }
    
    /// 渐变起点（默认左上角）
    public var startPoint: CGPoint = CGPoint(x: 0, y: 0) {
        didSet { gradientLayer.startPoint = startPoint }
    }
    
    /// 渐变终点（默认右下角）
    public var endPoint: CGPoint = CGPoint(x: 1, y: 1) {
        didSet { gradientLayer.endPoint = endPoint }
    }
    
    /// 渐变透明度（0~1）
    public var opacity: Float = 1 {
        didSet { gradientLayer.opacity = opacity }
    }
    
    /// 渐变图层
    private let gradientLayer = CAGradientLayer()
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        gradientLayer.contentsScale = UIScreen.main.scale
        layer.insertSublayer(gradientLayer, at: 0)
        isUserInteractionEnabled = false
    }
    
    // MARK: - Layout
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = bounds
        CATransaction.commit()
    }
    
    // MARK: - Update
    
    private func updateGradient() {
        gradientLayer.colors = colors.map { $0.resolvedColor(with: traitCollection).cgColor }
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard let previousTraitCollection = previousTraitCollection else { return }
        if previousTraitCollection.hasDifferentColorAppearance(comparedTo: traitCollection) {
            updateGradient()
        }
    }
}

