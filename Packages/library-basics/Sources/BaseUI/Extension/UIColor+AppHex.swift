//
//  UIColor+AppHex.swift
//  LibraryCommon
//
//  Created by Janlor on 4/22/26.
//

#if canImport(UIKit)
import UIKit

public extension UIColor {
    convenience init(appHex: UInt32) {
        let r = CGFloat((appHex >> 16) & 0xFF) / 255.0
        let g = CGFloat((appHex >> 8) & 0xFF) / 255.0
        let b = CGFloat(appHex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    convenience init(alphaHex: UInt32) {
        let r = CGFloat((alphaHex >> 16) & 0xFF) / 255.0
        let g = CGFloat((alphaHex >> 8) & 0xFF) / 255.0
        let b = CGFloat(alphaHex & 0xFF) / 255.0
        let a = CGFloat((alphaHex >> 24) & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    // Initializer for light color and automatic dark mode adjustment
    convenience init(lightColor: UIColor) {
        let darkColor = UIColor.adjustedColorForDarkMode(lightColor: lightColor)
        
        // Create elevated color (optional, can adjust as needed)
        let elevatedColor = UIColor.adjustedColorForDarkMode(lightColor: lightColor)
        
        self.init(light: lightColor, dark: darkColor, elevated: elevatedColor)
    }
    
    private static func adjustedColorForDarkMode(lightColor: UIColor) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        // Get the HSB values from the light color
        lightColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        // Adjust brightness and saturation for dark mode
        let adjustedBrightness = brightness * 0.6 // Reduce brightness to avoid white appearance
        let adjustedSaturation = min(saturation * 1.5, 1.0) // Enhance saturation for better visibility
        
        // Return the adjusted dark mode color
        return UIColor(hue: hue, saturation: adjustedSaturation, brightness: adjustedBrightness, alpha: alpha)
    }
}

#endif
