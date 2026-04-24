//
//  HistoryCell.swift
//  ModuleAI
//
//  Created by Janlor on 2024/10/24.
//

import UIKit
import BaseUI

class HistoryCell: UITableViewCell {

    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = .theme.tertieryGroupedBackground
        view.applyCapsule(.custom(16))
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.theme.subhead
        label.textColor = UIColor.theme.secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleView.leadingAnchor.constraint(equalTo: contentView.readableContentGuide.leadingAnchor, constant: 16-16),
            bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.readableContentGuide.trailingAnchor, constant: -16+16),

            titleLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8)
        ])
        
        let bottomLayout = bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        bottomLayout.priority = .required - 1 // 消除警告
        bottomLayout.isActive = true
    }
    
    func configure(with model: RecordModel?) {
        titleLabel.attributedText = model?.localAttributedText
    }
}
