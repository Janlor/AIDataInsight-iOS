//
//  AIChatUserCell.swift
//  ModuleAI
//
//  Created by Janlor on 2024/10/24.
//

import UIKit
import BaseUI

class AIChatUserCell: UICollectionViewCell {
    let horSpacing: CGFloat = 8
    let verSpacing: CGFloat = 8
    let ltSpacing: CGFloat = 38
    let contentEdge: UIEdgeInsets = UIEdgeInsets(top: 11.5, left: 16, bottom: 11.5, right: 16)
    
    let bubbleView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.applyTopRadius(.custom(21), bottomLeft: .custom(21))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .aiLabel
        label.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // borderLayer
    private lazy var borderLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor,
            UIColor(red: 1, green: 0.95, blue: 0.99, alpha: 1).cgColor
        ]
        layer.locations = [0, 1]
        layer.startPoint = CGPoint(x: 0.02, y: 0.14)
        layer.endPoint = CGPoint(x: 0.91, y: 0.91)
        bubbleView.layer.insertSublayer(layer, at: 0)
        return layer
    }()
    
    // backgroundLayer
    private lazy var backgroundLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 1, green: 0.96, blue: 0.99, alpha: 1).cgColor,
            UIColor(red: 1, green: 0.94, blue: 0.98, alpha: 1).cgColor,
            UIColor(red: 0.99, green: 0.93, blue: 0.97, alpha: 1).cgColor,
            UIColor(red: 1, green: 0.87, blue: 0.96, alpha: 1).cgColor
        ]
        layer.locations = [0, 0.28, 0.66, 1]
        layer.cornerRadius = 20
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        layer.startPoint = CGPoint(x: 0, y: 0.13)
        layer.endPoint = CGPoint(x: 0.89, y: 0.89)
        bubbleView.layer.insertSublayer(layer, above: borderLayer)
        return layer
    }()
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard let previousTraitCollection = previousTraitCollection else { return }
        if (previousTraitCollection.hasDifferentColorAppearance(comparedTo: traitCollection)) {
            setupBackground()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBackground()
        setupViews()
        setupData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        DispatchQueue.main.async {
            guard self.bubbleView.bounds.width > 0,
             self.bubbleView.bounds.height > 0 else {
                return
            }
            self.borderLayer.frame = self.bubbleView.bounds
            self.backgroundLayer.frame = self.bubbleView.bounds.insetBy(dx: 1, dy: 1)
        }
    }
    
    func setupViews() {
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verSpacing),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -verSpacing),
            bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -mSpacing),
            bubbleView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.readableContentGuide.leadingAnchor, constant: (mSpacing + ltSpacing - 8.0)),
            
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: contentEdge.top),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -contentEdge.bottom),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: contentEdge.left),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -contentEdge.right),
        ])
    }
    
    func setupData() {
        
    }
    
    private func setupBackground() {
        if traitCollection.userInterfaceStyle == .dark {
            borderLayer.isHidden = true
            backgroundLayer.colors = [
                UIColor(appHex: 0x1C1C1E).cgColor,
                UIColor(appHex: 0x25252C).cgColor,
                UIColor(appHex: 0x3C3039).cgColor,
                UIColor(appHex: 0x4B3645).cgColor
            ]
        } else {
            borderLayer.isHidden = false
            backgroundLayer.colors = [
                UIColor(red: 1, green: 0.96, blue: 0.99, alpha: 1).cgColor,
                UIColor(red: 1, green: 0.94, blue: 0.98, alpha: 1).cgColor,
                UIColor(red: 0.99, green: 0.93, blue: 0.97, alpha: 1).cgColor,
                UIColor(red: 1, green: 0.87, blue: 0.96, alpha: 1).cgColor
            ]
        }
    }

    
    func configure(with text: String) {
        messageLabel.text = text
    }
}
