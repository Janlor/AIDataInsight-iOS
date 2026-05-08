//
//  AppRuntimeSettings.swift
//  LibraryBasics
//
//  Created by OpenAI on 2025/2/14.
//

import Foundation

public enum AppRuntimeSettings {
    public static let customUserDefineKey = "CustomUserDefine"
    public static let customEnvKey = "CustomEnv"

    public static func infoDictionary(bundle: Bundle = .main) -> [String: Any] {
        bundle.infoDictionary ?? [:]
    }

    public static func customUserDefine(bundle: Bundle = .main) -> [String: Any] {
        let info = infoDictionary(bundle: bundle)
        if let dictionary = info[customUserDefineKey] as? [String: Any] {
            return dictionary
        }
        return [:]
    }
}
