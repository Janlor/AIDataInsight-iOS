//
//  VerticalTitleValuesCell.swift
//  ModuleStatistic
//
//  Created by Janlor on 6/26/24.
//

import UIKit
import BaseUI

class VerticalTitleValuesCell: UICollectionViewCell {
    var contentInset: UIEdgeInsets = .zero {
        didSet {
            guard contentInset != oldValue else { return }
            updateConstraintsForContentInset()
        }
    }
    
    var space: CGFloat = 5 {
        didSet {
            guard space != oldValue else { return }
            updateConstraintsForSpacing()
        }
    }
    
    var color: UIColor? {
        didSet {
            colorView.isHidden = color == nil
            colorView.backgroundColor = color
        }
    }
    
    var colorSize: CGSize = .zero {
        didSet {
            guard colorSize != oldValue else { return }
            colorViewWidth.constant = colorSize.width
            colorViewHeight.constant = colorSize.height
            titleLabelLeading.constant = colorSize.width == 0 ? 0 : 4
        }
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var attributedTitle: NSAttributedString? {
        didSet {
            titleLabel.attributedText = attributedTitle
        }
    }
    
    var titleAlignment: NSTextAlignment = .natural {
        didSet {
            titleLabel.textAlignment = titleAlignment
        }
    }
    
    var value: String? {
        didSet {
            valueLabel.text = value
        }
    }
    
    var attributedValue: NSAttributedString? {
        didSet {
            valueLabel.attributedText = attributedValue
        }
    }
    
    var valueAlignment: NSTextAlignment = .natural {
        didSet {
            valueLabel.textAlignment = valueAlignment
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
        label.textColor = .theme.tertieryLabel
        label.themeFont = .theme.caption1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .theme.label
        label.themeFont = .theme.body1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var colorViewLeading: NSLayoutConstraint!
    private var colorViewWidth: NSLayoutConstraint!
    private var colorViewHeight: NSLayoutConstraint!
    private var titleLabelTop: NSLayoutConstraint!
    private var valueLabelTop: NSLayoutConstraint!
    private var valueLabelBottom: NSLayoutConstraint!
    private var titleLabelLeading: NSLayoutConstraint!
    private var titleLabelTrailing: NSLayoutConstraint!
    private var valueLabelTrailing: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(colorView)
        addSubview(titleLabel)
        addSubview(valueLabel)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension VerticalTitleValuesCell {
    func setupConstraints() {
//        let margins = layoutMarginsGuide
        
        colorViewLeading = colorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentInset.left)
        colorViewWidth = colorView.widthAnchor.constraint(equalToConstant: 0)
        colorViewHeight = colorView.heightAnchor.constraint(equalToConstant: 0)
        titleLabelTop = titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: contentInset.top)
        valueLabelTop = valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: sSpacing)
        valueLabelBottom = valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: contentInset.bottom)
        titleLabelLeading = titleLabel.leadingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: 0)
        titleLabelTrailing = titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: contentInset.right)
        valueLabelTrailing = valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: contentInset.right)
        
        NSLayoutConstraint.activate([
            colorViewLeading,
            colorViewWidth,
            colorViewHeight,
            colorView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            titleLabelTop,
            valueLabelTop,
            valueLabelBottom,
            titleLabelLeading,
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            titleLabelTrailing,
            valueLabelTrailing
        ])
    }
    
    func updateConstraintsForContentInset() {
        colorViewLeading.constant = contentInset.left
        titleLabelTop.constant = contentInset.top
        valueLabelBottom.constant = contentInset.bottom
        titleLabelTrailing.constant = contentInset.right
        valueLabelTrailing.constant = contentInset.right
    }
    
    func updateConstraintsForSpacing() {
        valueLabelTop.constant = space
    }
}
