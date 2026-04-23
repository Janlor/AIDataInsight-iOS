//
//  PolicyManager.swift
//  LibraryCommon
//
//  Created by Janlor on 4/22/26.
//

import Foundation
import Environment

public class PolicyManager {
    public static var privacyPolicyURL: String {
        return Environment.server.privacyPolicyURL
    }
    static let agreedPrivatePolicyVersionKey = "kAgreedPrivatePolicyVersion"
    
    /// 最新的版本号
    static func latestVersionDict() -> [String: String] {
        return ["2": "2.0"]
    }
    
    /// 保存用户同意的隐私政策2和用户协议1版本号
    /// - Parameter versionDict: 例如:  ["1": "12.0", "2": "10.0"]
    static func saveAgreedVersionDict(_ versionDict: [String: String]) {
        guard !versionDict.isEmpty else { return }
        let userDefaults = UserDefaults.standard
        var savedDict = userDefaults.dictionary(forKey: agreedPrivatePolicyVersionKey) as? [String: String] ?? [:]
        versionDict.forEach { savedDict[$0.key] = $0.value }
        userDefaults.set(savedDict, forKey: agreedPrivatePolicyVersionKey)
        userDefaults.synchronize()
    }
    
    /// 是否同意所有协议
    /// - Returns: 是否同意所有协议
    static func isAgreedAllPolicyAgreement() -> Bool {
        let userDefaults = UserDefaults.standard
        guard let savedDict = userDefaults.dictionary(forKey: agreedPrivatePolicyVersionKey) as? [String: String] else {
            return false
        }
        
        let latest = latestVersionDict()
        let result = areAllValuesGreaterOrEqual(dictA: savedDict, dictB: latest)
        return result
    }

    static func areAllValuesGreaterOrEqual(dictA: [String: String], dictB: [String: String]) -> Bool {
        for (key, valueB) in dictB {
            if let valueA = dictA[key], valueA.greaterOrEqualVersion(than: valueB) {
                continue
            } else {
                return false
            }
        }
        return true
    }
}
