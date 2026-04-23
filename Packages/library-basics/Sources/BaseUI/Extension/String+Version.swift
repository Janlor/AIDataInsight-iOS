//
//  String+Version.swift
//  LibraryCommon
//
//  Created by Janlor on 4/22/26.
//

import Foundation

public enum VersionComparisonResult {
    case greaterThan
    case equal
    case lessThan
}

public extension String {
    private func compareVersionComponents(_ v1: String, _ v2: String) -> VersionComparisonResult {
        let parts1 = v1.split(separator: ".").map { Int($0) ?? 0 }
        let parts2 = v2.split(separator: ".").map { Int($0) ?? 0 }
        let count = max(parts1.count, parts2.count)

        for i in 0..<count {
            let p1 = i < parts1.count ? parts1[i] : 0
            let p2 = i < parts2.count ? parts2[i] : 0
            if p1 < p2 {
                return .lessThan
            } else if p1 > p2 {
                return .greaterThan
            }
        }
        return .equal
    }
    
    // Instance method (for the wrapped string)
    func compareVersion(than version: String) -> VersionComparisonResult {
        return compareVersionComponents(self, version)
    }
    
    // Static method
    func greaterOrEqualVersion(than version: String) -> Bool {
        let result = self.compareVersion(than: version)
        switch result {
        case .greaterThan:
            return true
        case .equal:
            return true
        case .lessThan:
            return false
        }
    }
}
