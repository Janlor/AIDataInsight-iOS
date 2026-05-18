import Foundation

public struct UserPreferenceRecord: Equatable, Sendable {
    public let key: String
    public var value: String
    public var updatedAt: Date

    public init(key: String, value: String, updatedAt: Date = .now) {
        self.key = key
        self.value = value
        self.updatedAt = updatedAt
    }
}

public enum PersistenceBoundary {
    public static let sensitiveSessionStorage = "Keychain"
    public static let nonSensitiveCacheStorage = "SwiftData"
}
