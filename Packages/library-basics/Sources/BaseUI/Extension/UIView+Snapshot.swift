//
//  UIView+Snapshot.swift
//  ModuleMessage
//
//  Created by Janlor on 4/22/26.
//

import UIKit

public extension UIView {
    func appSnapshot(scrollView: UIScrollView) -> UIImage? {
        var height: CGFloat = scrollView.contentSize.height
        height += safeAreaInsets.top
        height += safeAreaInsets.bottom
        let width: CGFloat = scrollView.contentSize.width
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let savedContentOffset = scrollView.contentOffset
        let savedFrame = frame
        
        scrollView.contentOffset = CGPoint.zero
        frame = CGRect(origin: .zero, size: size)
        
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        scrollView.contentOffset = savedContentOffset
        frame = savedFrame
        
        UIGraphicsEndImageContext()
        
        return image
    }
}
