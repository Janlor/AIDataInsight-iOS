//
//  AIChatCell.swift
//  ModuleAI
//
//  Created by Janlor on 2024/10/23.
//

import UIKit
import BaseUI

class AIChatCell: UICollectionViewCell {
    let horSpacing: CGFloat = 8
    let verSpacing: CGFloat = 8
    let ltSpacing: CGFloat = 38
    let contentEdge: UIEdgeInsets = UIEdgeInsets(top: 11.5, left: 16, bottom: 11.5, right: 16)
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = .theme.secondaryGroupedBackground
        view.layer.borderColor = UIColor.aiSeparator.cgColor
        view.layer.borderWidth = 0.5
        view.applyTopRadius(.custom(21), bottomRight: .custom(21))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var bubbleViewTrailing: NSLayoutConstraint?
    var bubbleViewBottom: NSLayoutConstraint!
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .theme.subhead
        label.textColor = .theme.label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var messageLabelBottom: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        updateViews()
        addNotifications()
        setupData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard let previousTraitCollection = previousTraitCollection else { return }
        if (previousTraitCollection.hasDifferentColorAppearance(comparedTo: traitCollection)) {
            bubbleView.layer.borderColor = UIColor.aiSeparator.cgColor
        }
    }
    
    func setupViews() {
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        
        messageLabelBottom = messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -contentEdge.bottom)
        bubbleViewBottom = bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -verSpacing)
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verSpacing),
            bubbleViewBottom,
            
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: contentEdge.top),
            messageLabelBottom,
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: contentEdge.left),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -contentEdge.right),
        ])
    }
    
    func updateViews() {
        bubbleViewTrailing = bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.readableContentGuide.trailingAnchor, constant: -(mSpacing + ltSpacing) + 8.0)
        NSLayoutConstraint.activate([
            bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: mSpacing),
            bubbleViewTrailing!,
        ])
    }
    
    func addNotifications() {
        
    }
    
    func setupData() {
        
    }
    
    func configure(with text: String) {
        messageLabel.text = text
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        // 确保在设置遮罩之前 bubbleView 有有效的 frame
//        guard bubbleView.bounds.width > 0, bubbleView.bounds.height > 0 else { return }
//        
//        // 创建一个新的路径
//        let path = UIBezierPath()
//        let bounds = bubbleView.bounds
//        
//        // 从左上角开始，顺时针绘制
//        // 左上角 - 12pt
//        path.move(to: CGPoint(x: bounds.minX + 12, y: bounds.minY))
//        path.addArc(withCenter: CGPoint(x: bounds.minX + 12, y: bounds.minY + 12),
//                    radius: 12,
//                    startAngle: CGFloat(-Double.pi/2),
//                    endAngle: CGFloat(Double.pi),
//                    clockwise: false)
//        
//        // 左下角 - 4pt
//        path.addLine(to: CGPoint(x: bounds.minX, y: bounds.maxY - 4))
//        path.addArc(withCenter: CGPoint(x: bounds.minX + 4, y: bounds.maxY - 4),
//                    radius: 4,
//                    startAngle: CGFloat(Double.pi),
//                    endAngle: CGFloat(Double.pi/2),
//                    clockwise: false)
//        
//        // 右下角 - 12pt
//        path.addLine(to: CGPoint(x: bounds.maxX - 12, y: bounds.maxY))
//        path.addArc(withCenter: CGPoint(x: bounds.maxX - 12, y: bounds.maxY - 12),
//                    radius: 12,
//                    startAngle: CGFloat(Double.pi/2),
//                    endAngle: 0,
//                    clockwise: false)
//        
//        // 右上角 - 12pt
//        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY + 12))
//        path.addArc(withCenter: CGPoint(x: bounds.maxX - 12, y: bounds.minY + 12),
//                    radius: 12,
//                    startAngle: 0,
//                    endAngle: CGFloat(-Double.pi/2),
//                    clockwise: false)
//        
//        path.close()
//        
//        // 应用遮罩
//        let maskLayer = CAShapeLayer()
//        maskLayer.path = path.cgPath
//        bubbleView.layer.mask = maskLayer
//    }
}
