//
//  UIImage+Gradient.swift
//  LibraryCommon
//
//  Created by Janlor on 6/17/24.
//

import UIKit

extension UIImage {
    static func gradientImage(colors: [UIColor], locations: [NSNumber]? = nil, startPoint: CGPoint, endPoint: CGPoint, size: CGSize) -> UIImage? {
        let layer = CAGradientLayer()
        layer.frame = CGRect(origin: .zero, size: size)
        layer.colors = colors.map { $0.cgColor }
        layer.locations = locations
        layer.startPoint = startPoint
        layer.endPoint = endPoint
        
        UIGraphicsBeginImageContextWithOptions(layer.bounds.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
