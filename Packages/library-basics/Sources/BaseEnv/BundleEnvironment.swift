// BundleEnvironment.swift

import Foundation

public extension Bundle {
    /// Application running environment.
    ///
    /// - debug: Application is running in debug mode.
    /// - testFlight: Application is installed from Test Flight.
    /// - appStore: Application is installed from the App Store.
    enum BundleEnvironment {
        /// Application is running in debug mode.
        case debug
        /// Application is installed from Test Flight.
        case testFlight
        /// Application is installed from the App Store.
        case appStore
    }

    /// Current inferred app environment.
    var inferredEnvironment: BundleEnvironment {
        #if DEBUG
        return .debug

        #elseif targetEnvironment(simulator)
        return .debug

        #else
        if path(forResource: "embedded", ofType: "mobileprovision") != nil {
            return .testFlight
        }

        guard let appStoreReceiptUrl = appStoreReceiptURL else {
            return .debug
        }

        if appStoreReceiptUrl.lastPathComponent.lowercased() == "sandboxreceipt" {
            return .testFlight
        }

        if appStoreReceiptUrl.path.lowercased().contains("simulator") {
            return .debug
        }

        return .appStore
        #endif
    }

    /// Application name (if applicable).
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }

    /// App current build number (if applicable).
    var buildNumber: String? {
        return object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
    }

    /// App's current version number (if applicable).
    var version: String? {
        return object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}
