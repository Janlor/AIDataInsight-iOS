//
//  LeftAlignedTitleValueCollectionView.swift
//  ModuleStatistic
//
//  Created by Janlor on 4/22/26.
//

import UIKit
import BaseKit
import BaseUI
import SwifterSwift

class LeftAlignedTitleValuesView<T>: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout where T: Equatable {
    struct Configuration {
        var sectionInset: UIEdgeInsets = .zero
        var minLineSpacing: CGFloat = 10.0
        var minInteritemSpacing: CGFloat = 24.0
        
        var itemontentInset: UIEdgeInsets = .zero
        var itemSpacing: CGFloat = 5
        var itemColorSize: CGSize = .zero
    }
    
    public var didChangeToHeight: ((_ height: CGFloat) -> Void)?
    
    public var displayColorFor: ((T?) -> UIColor?)?
    
    public var displayTitleFor: ((T?) -> NSAttributedString?)? = {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.theme.caption1,
            .foregroundColor: UIColor.theme.label
        ]
        let value = String(describing: $0)
        return NSAttributedString(string: value ,attributes: attributes)
    }
    
    public var displayValueFor: ((T?) -> NSAttributedString?)? = {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.theme.title4,
            .foregroundColor: UIColor.theme.label
        ]
        let value = String(describing: $0)
        return NSAttributedString(string: value ,attributes: attributes)
    }
        
    public var dataSource: [T] = [T]() {
        didSet {
            reloadData()
//            setNeedsLayout()
        }
    }
    
    private var config: Configuration = Configuration()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewLeftAlignedLayout()
        layout.estimatedItemSize = CGSize(width: 60, height: 40)
        layout.minimumLineSpacing = config.minLineSpacing
        layout.minimumInteritemSpacing = config.minInteritemSpacing
        layout.sectionInset = config.sectionInset
        layout.scrollDirection = .vertical
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = false
        view.isScrollEnabled = false
        view.scrollsToTop = false
        view.dataSource = self
        view.delegate = self
        view.register(cellWithClass: VerticalTitleValuesCell.self)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var collectionViewHeight: NSLayoutConstraint!
    
    init(config: Configuration) {
        super.init(frame: .zero)
        self.config = config
        setupUI()
        setupData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        reloadData()
    }
    
    private func reloadData() {
        layoutIfNeeded()
        collectionView.reloadData {
            let height = self.collectionView.collectionViewLayout.collectionViewContentSize.height
            if height != self.collectionViewHeight.constant {
                self.collectionViewHeight.constant = height
                self.layoutIfNeeded()
                self.didChangeToHeight?(height)
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: VerticalTitleValuesCell.self, for: indexPath)
        let model = dataSource[indexPath.item]
        cell.colorSize = config.itemColorSize
        cell.color = displayColorFor?(model)
        cell.attributedTitle = displayTitleFor?(model)
        cell.attributedValue = displayValueFor?(model)
        return cell
    }
}

private extension LeftAlignedTitleValuesView {
    func setupUI() {
        addSubview(collectionView)
                
        collectionViewHeight = collectionView.heightAnchor.constraint(equalToConstant: 0.0)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionViewHeight
        ])
        let bottomLayout = collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        bottomLayout.priority = .required - 1 // 消除警告
        bottomLayout.isActive = true
    }
}

private extension LeftAlignedTitleValuesView {
    func setupData() {
        
    }
}
