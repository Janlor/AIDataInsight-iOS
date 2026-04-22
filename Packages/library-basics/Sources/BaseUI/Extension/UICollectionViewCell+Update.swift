//
//  UICollectionViewCell+Update.swift
//  LibraryCommon
//
//  Created by Janlor on 2024/11/5.
//

import UIKit

public extension UICollectionViewCell {
    func updateCollectionView() {
        // 触发 cell 重新布局
        self.setNeedsLayout()

        // 通知 collection view 重新计算布局
        if let collectionView = self.superview as? UICollectionView {
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
}
