//
//  ThemeManager.swift
//  ThemeKit
//
//  Created by Janlor on 2025/8/5.
//

import UIKit

@available(iOS 13.0, *)
public final class ThemeManager {
    public static let shared = ThemeManager()

    private var colorMap: [ThemeColorKey: ThemeColorDefinition] = [:]
    private var fontMap: [String: ThemeFontItem] = [:]

    private let colorFileName = "theme_colors"
    private let fontFileName = "theme_fonts"

    private init() {}

    // MARK: - Dynamic Font Control

    public var isDynamicFontEnabled: Bool {
        get { !UserDefaults.standard.bool(forKey: "DynamicFont") }
        set { UserDefaults.standard.set(!newValue, forKey: "DynamicFont") }
    }

    // MARK: - Public Load Entry (Async)

    public func loadThemeAsync(colorURL: URL? = nil, fontURL: URL? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.loadTheme(colorURL: colorURL, fontURL: fontURL)
            DispatchQueue.main.async { completion?() }
        }
    }

    // MARK: - Public Load Entry (Sync)

    public func loadTheme(colorURL: URL? = nil, fontURL: URL? = nil) {
        if let colorURL = colorURL {
            loadColorTheme(url: colorURL)
        }
        if let fontURL = fontURL {
            loadFontTheme(url: fontURL)
        }
    }

    // MARK: - Lazy Accessors

    public func color(for key: ThemeColorKey, trait: UITraitCollection = .current) -> UIColor {
        // ⚠️ 主线程懒加载，建议在启动阶段预加载
        if colorMap.isEmpty, let url = Bundle.module.url(forResource: colorFileName, withExtension: "json") {
            loadColorTheme(url: url)
        }
        return colorMap[key]?.uiColor(for: trait) ?? .clear
    }

    public func font(for key: String) -> UIFont {
        // ⚠️ 主线程懒加载，建议在启动阶段预加载
        if fontMap.isEmpty, let url = Bundle.module.url(forResource: fontFileName, withExtension: "json")  {
            loadFontTheme(url: url)
        }
        return fontMap[key]?.font(dynamicEnabled: isDynamicFontEnabled) ?? UIFont.systemFont(ofSize: 14)
    }

    // MARK: - Internal Loaders

    private func loadColorTheme(url fileURL: URL) {
        if let decoded: [String: ThemeColorDefinition] = loadJSON(from: fileURL) {
            self.colorMap = decoded.compactMapKeys { ThemeColorKey(rawValue: $0) }
        }
    }

    private func loadFontTheme(url fileURL: URL) {
        if let decoded: [String: ThemeFontItem] = loadJSON(from: fileURL) {
            self.fontMap = decoded
        }
    }

    // MARK: - Generic JSON Loader

    private func loadJSON<T: Decodable>(from url: URL) -> T? {
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            assertionFailure("Failed to decode \(T.self): \(error)")
            return nil
        }
    }
}

// MARK: - Utility
private extension Dictionary {
    func compactMapKeys<T>(_ transform: (Key) -> T?) -> [T: Value] {
        var result = [T: Value]()
        for (key, value) in self {
            if let newKey = transform(key) {
                result[newKey] = value
            }
        }
        return result
    }
}

