//
//  AIBarChartLegendCell.swift
//  ModuleAI
//
//  Created by Janlor on 2024/10/30.
//

import UIKit
import BaseUI

class AIBarChartLegendCell: UICollectionViewCell {
    var color: UIColor? {
        didSet {
            colorView.backgroundColor = color
        }
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    private lazy var colorView: UIView = {
        let view = UIView()
        view.applyCorner(.custom(1.0))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .theme.label
        label.font = UIFont.systemFont(ofSize: 10)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(colorView)
        addSubview(titleLabel)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AIBarChartLegendCell {
    static func calulatedSize(_ title: String, maxSize: CGSize) -> CGSize {
        let titleSize = title.textSize(font: .theme.caption1, maxSize: maxSize)
        let width = titleSize.width + 2 + 2
        let height = titleSize.height
        return CGSize(width: width, height: height)
    }
}

private extension AIBarChartLegendCell {
    func setupConstraints() {
        let contentInset: UIEdgeInsets = .zero
        NSLayoutConstraint.activate([
            colorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentInset.left),
            colorView.widthAnchor.constraint(equalToConstant: 2),
            colorView.heightAnchor.constraint(equalToConstant: 8),
            colorView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: contentInset.top),
            titleLabel.leadingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: 2),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: contentInset.right),
        ])
        
        let bottomLayout = titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: contentInset.bottom)
        bottomLayout.priority = .required - 1 // 消除警告
        bottomLayout.isActive = true
    }
}
