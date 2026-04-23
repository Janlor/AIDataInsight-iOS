//
//  ImageTextButton.swift
//  ModuleApprove
//
//  Created by Janlor on 4/22/26.
//

import UIKit

public enum ButtonImagePosition {
    case left, right, top, bottom
}

public class ImageTextButton: UIButton {
    public var imagePosition: ButtonImagePosition = .left {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var imageTextSpacing: CGFloat = 8.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var contentInsets: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let imageView = imageView, let titleLabel = titleLabel else {
            return
        }
        
        let contentRect = bounds.inset(by: contentInsets)
        let imageSize = imageView.intrinsicContentSize
        let titleSize = titleLabel.intrinsicContentSize
        
        var imageFrame = CGRect.zero
        var titleFrame = CGRect.zero
        
        switch imagePosition {
        case .left:
            imageFrame = CGRect(x: contentRect.minX, y: contentRect.midY - imageSize.height / 2, width: imageSize.width, height: imageSize.height)
            titleFrame = CGRect(x: imageFrame.maxX + imageTextSpacing, y: contentRect.midY - titleSize.height / 2, width: titleSize.width, height: titleSize.height)
            
        case .right:
            titleFrame = CGRect(x: contentRect.minX, y: contentRect.midY - titleSize.height / 2, width: titleSize.width, height: titleSize.height)
            imageFrame = CGRect(x: titleFrame.maxX + imageTextSpacing, y: contentRect.midY - imageSize.height / 2, width: imageSize.width, height: imageSize.height)
            
        case .top:
            imageFrame = CGRect(x: contentRect.midX - imageSize.width / 2, y: contentRect.minY, width: imageSize.width, height: imageSize.height)
            titleFrame = CGRect(x: contentRect.midX - titleSize.width / 2, y: imageFrame.maxY + imageTextSpacing, width: titleSize.width, height: titleSize.height)
            
        case .bottom:
            titleFrame = CGRect(x: contentRect.midX - titleSize.width / 2, y: contentRect.minY, width: titleSize.width, height: titleSize.height)
            imageFrame = CGRect(x: contentRect.midX - imageSize.width / 2, y: titleFrame.maxY + imageTextSpacing, width: imageSize.width, height: imageSize.height)
        }
        
        imageView.frame = imageFrame
        titleLabel.frame = titleFrame
    }
    
    public override var intrinsicContentSize: CGSize {
        guard let imageView = imageView, let titleLabel = titleLabel else {
            return super.intrinsicContentSize
        }
        
        let imageSize = imageView.intrinsicContentSize
        let titleSize = titleLabel.intrinsicContentSize
        
        var contentWidth: CGFloat = 0
        var contentHeight: CGFloat = 0
        
        switch imagePosition {
        case .left, .right:
            contentWidth = imageSize.width + imageTextSpacing + titleSize.width
            contentHeight = max(imageSize.height, titleSize.height)
            
        case .top, .bottom:
            contentWidth = max(imageSize.width, titleSize.width)
            contentHeight = imageSize.height + imageTextSpacing + titleSize.height
        }
        
        contentWidth += contentInsets.left + contentInsets.right
        contentHeight += contentInsets.top + contentInsets.bottom
        
        return CGSize(width: contentWidth, height: contentHeight)
    }
}

