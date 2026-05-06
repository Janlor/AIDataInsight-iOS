//
//  AIBarChartLegendView.swift
//  ModuleAI
//
//  Created by Janlor on 2024/10/30.
//

import UIKit
import BaseKit
import BaseUI
import SwifterSwift

class AIBarChartLegendView<T>: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout where T: Equatable {
    struct Configuration {
        var sectionInset: UIEdgeInsets = .zero
        var minLineSpacing: CGFloat = 8.0
        var minInteritemSpacing: CGFloat = 8.0
    }
    
    public var didChangeToHeight: ((_ height: CGFloat) -> Void)?
    public var displayColorFor: ((T?) -> UIColor?)?
    public var displayTitleFor: ((T?) -> String?)?
    
    public var dataSource: [T] = [T]() {
        didSet {
            reloadData()
        }
    }
    
    private var config: Configuration = Configuration()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewLeftAlignedLayout()
        layout.estimatedItemSize = .zero
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
        view.register(cellWithClass: AIBarChartLegendCell.self)
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
    
    private func reloadData() {
        collectionView.reloadData()
        collectionView.performBatchUpdates(nil) { _ in
            let height = self.collectionView.collectionViewLayout.collectionViewContentSize.height
            if height != self.collectionViewHeight.constant {
                self.collectionViewHeight.constant = height
                self.setNeedsLayout()
                self.didChangeToHeight?(height)
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: AIBarChartLegendCell.self, for: indexPath)
        let model = dataSource[indexPath.item]
        cell.color = displayColorFor?(model)
        cell.title = displayTitleFor?(model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let model = dataSource[indexPath.item]
        let title = displayTitleFor?(model) ?? " "
        let maxWidth = collectionView.bounds.width - config.sectionInset.left - config.sectionInset.right
        let size = AIBarChartLegendCell.calulatedSize(title, maxSize: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
        return size
    }
}

private extension AIBarChartLegendView {
    func setupUI() {
        addSubview(collectionView)
                
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        collectionViewHeight = collectionView.heightAnchor.constraint(equalToConstant: 0.0)
        collectionViewHeight.isActive = true
    }
}

private extension AIBarChartLegendView {
    func setupData() {
        
    }
}
