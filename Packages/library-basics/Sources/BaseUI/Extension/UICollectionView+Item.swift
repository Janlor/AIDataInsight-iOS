//
//  UICollectionViewExtension.swift
//  LibraryCommon
//
//  Created by Janlor on 4/22/26.
//

import UIKit

public extension Int {
    /// 根据最大宽度计算一行显示的 item 个数
    /// - Parameters:
    ///   - width: collectionView 宽度
    ///   - count: iPhone 设计稿上一行显示的个数
    static func columnCount(_ width: CGFloat, count: Int) -> Int {
        // 目前 iPhone 15 Pro Max 最宽，430pt.
        return columnCount(width, base: 530.0, count: count)
    }
    
    /// 根据最大宽度计算一行显示的 item 个数
    /// - Parameters:
    ///   - width: collectionView 宽度
    ///   - base: 计算基数 一般传最宽 iPhone 的尺寸
    ///   - count: iPhone 设计稿上一行显示的个数
    static func columnCount(_ width: CGFloat, base: CGFloat, count: Int) -> Int {
        return Int(ceil(width / base) * CGFloat(count))
    }
}

public extension AppWrapper where Base: UICollectionView {
    /// 根据一行显示的单元格个数计算单元格宽度
    /// 仅适用于流式布局 UICollectionViewFlowLayout 竖直方向滚动
    /// - Parameter count: iPhone 设计稿上一行显示的个数 会根据最大宽度计算显示个数
    func itemWidth(_ count: Int) -> CGFloat {
        let maxWidth = base.bounds.size.width
        let columnCount = Int.columnCount(maxWidth, count: count)
        guard let layout = base.collectionViewLayout as? UICollectionViewFlowLayout else {
            return 0
        }
        let hSectionInset = layout.sectionInset.left + layout.sectionInset.right
        let totalSpacing = CGFloat(columnCount - 1) * layout.minimumInteritemSpacing
        let itemWidth = floor((maxWidth - hSectionInset - totalSpacing) / CGFloat(columnCount))
        return itemWidth
    }
}
