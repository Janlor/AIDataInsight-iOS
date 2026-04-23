//
//  ThemeFontItem.swift
//  ThemeKit
//
//  Created by Janlor on 4/22/26.
//

import UIKit

public struct ThemeFontItem: Decodable {
    public let size: CGFloat
    public let weight: UIFont.Weight
    public let textStyle: UIFont.TextStyle

    enum CodingKeys: String, CodingKey {
        case size, weight, textStyle
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        size = try container.decode(CGFloat.self, forKey: .size)
        
        let weightStr = try container.decode(String.self, forKey: .weight)
        weight = UIFont.Weight(rawValue: ThemeFontItem.weightMap[weightStr.lowercased()] ?? UIFont.Weight.regular.rawValue)

        let textStyleStr = try container.decode(String.self, forKey: .textStyle)
        textStyle = UIFont.TextStyle(rawValue: textStyleStr)
    }

    private static let weightMap: [String: CGFloat] = [
        "ultralight": UIFont.Weight.ultraLight.rawValue,
        "thin": UIFont.Weight.thin.rawValue,
        "light": UIFont.Weight.light.rawValue,
        "regular": UIFont.Weight.regular.rawValue,
        "medium": UIFont.Weight.medium.rawValue,
        "semibold": UIFont.Weight.semibold.rawValue,
        "bold": UIFont.Weight.bold.rawValue,
        "heavy": UIFont.Weight.heavy.rawValue,
        "black": UIFont.Weight.black.rawValue
    ]

    public func font(dynamicEnabled: Bool) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        if dynamicEnabled {
            return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: base)
        } else {
            return base
        }
    }
}
