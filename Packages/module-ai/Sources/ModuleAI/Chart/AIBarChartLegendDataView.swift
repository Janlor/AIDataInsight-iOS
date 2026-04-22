//
//  AIBarChartLegendDataView.swift
//  ModuleStatistic
//
//  Created by Janlor on 6/27/24.
//

import UIKit
import BaseKit
import BaseUI

class AIBarChartLegendDataView<T>: UIView where T: Hashable {
    public var didChangeToHeight: ((_ height: CGFloat) -> Void)?
    public var displayColorFor: ((T?) -> UIColor?)?
    public var displayTitleFor: ((T?) -> NSAttributedString?)?
    public var displayValueFor: ((T?) -> NSAttributedString?)?
    
    var dataSource: [T] = [T]() {
        didSet {
            titleValuesView.dataSource = dataSource
        }
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .theme.label
        label.themeFont = .theme.title3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var titleValuesView: LeftAlignedTitleValuesView<T> = {
        var config = LeftAlignedTitleValuesView<T>.Configuration()
        config.minLineSpacing = 12.0
        config.minInteritemSpacing = 38.0
        config.itemColorSize = CGSize(width: 2, height: 10)
        let view = LeftAlignedTitleValuesView(config: config)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension AIBarChartLegendDataView {
    func setupUI() {
        addSubview(titleLabel)
        addSubview(titleValuesView)
                
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            titleValuesView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            titleValuesView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleValuesView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
        
        let bottomLayout = titleValuesView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        bottomLayout.priority = .required - 1 // 消除警告
        bottomLayout.isActive = true
        
        setupTitleValueView()
    }
    
    func setupTitleValueView() {
        titleValuesView.didChangeToHeight = { [weak self] h in
            var height = h
            if h > 0 { height += (12 + 17 + 12 + 12) }
            self?.didChangeToHeight?(height)
        }
        titleValuesView.displayColorFor = { [weak self] model in
            return self?.displayColorFor?(model)
        }
        titleValuesView.displayTitleFor = { [weak self] model in
            return self?.displayTitleFor?(model)
        }
        titleValuesView.displayValueFor = { [weak self] model in
            return self?.displayValueFor?(model)
        }
    }
}

private extension AIBarChartLegendDataView {
    func setupData() {
        
    }
}
