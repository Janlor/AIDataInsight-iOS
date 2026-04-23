//
//  UICollectionViewLeftAlignedLayout.swift
//  LibraryBasics
//
//  Created by Janlor on 4/22/26.
//

import UIKit

open class UICollectionViewLeftAlignedLayout: UICollectionViewFlowLayout {
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return super.layoutAttributesForElements(in: rect)?.map { attributes in
            if attributes.representedElementKind == nil {
                return layoutAttributesForItem(at: attributes.indexPath) ?? attributes
            }
            return attributes
        }
    }

    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let currentItemAttributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes,
              let _ = collectionView else {
            return nil
        }
        
        if scrollDirection == .vertical {
            if indexPath.item != 0,
               let previousFrame = layoutAttributesForItem(at: IndexPath(item: indexPath.item - 1, section: indexPath.section))?.frame,
               currentItemAttributes.frame.intersects(CGRect(x: -.infinity, y: previousFrame.origin.y, width: .infinity, height: previousFrame.size.height)) {
                currentItemAttributes.frame.origin.x = previousFrame.origin.x + previousFrame.size.width + evaluatedMinimumInteritemSpacingForSection(at: indexPath.section)
            } else {
                currentItemAttributes.frame.origin.x = evaluatedSectionInsetForSection(at: indexPath.section).left
            }
        } else {
            if indexPath.item != 0,
               let previousFrame = layoutAttributesForItem(at: IndexPath(item: indexPath.item - 1, section: indexPath.section))?.frame,
               currentItemAttributes.frame.intersects(CGRect(x: previousFrame.origin.x, y: -.infinity, width: previousFrame.size.width, height: .infinity)) {
                currentItemAttributes.frame.origin.y = previousFrame.origin.y + previousFrame.size.height + evaluatedMinimumInteritemSpacingForSection(at: indexPath.section)
            } else {
                currentItemAttributes.frame.origin.y = evaluatedSectionInsetForSection(at: indexPath.section).top
            }
        }
        
        return currentItemAttributes
    }

    private func evaluatedMinimumInteritemSpacingForSection(at section: Int) -> CGFloat {
        return (collectionView?.delegate as? UICollectionViewDelegateFlowLayout)?
            .collectionView?(collectionView!, layout: self, minimumInteritemSpacingForSectionAt: section) ?? minimumInteritemSpacing
    }

    private func evaluatedSectionInsetForSection(at section: Int) -> UIEdgeInsets {
        return (collectionView?.delegate as? UICollectionViewDelegateFlowLayout)?
            .collectionView?(collectionView!, layout: self, insetForSectionAt: section) ?? sectionInset
    }
}
