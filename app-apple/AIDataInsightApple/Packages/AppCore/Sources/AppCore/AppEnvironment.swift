import Foundation

public enum AppEnvironment: String, CaseIterable, Identifiable, Sendable {
    case mock
    case local
    case dev
    case test
    case pre
    case prod

    public var id: String { rawValue }
}

public struct APIEnvironment: Equatable, Sendable {
    public let name: AppEnvironment
    public let baseURL: URL
    public let description: String?

    public init(name: AppEnvironment, baseURL: URL, description: String? = nil) {
        self.name = name
        self.baseURL = baseURL
        self.description = description
    }

    public static let mock = APIEnvironment(
        name: .mock,
        baseURL: URL(string: "https://m1.apifoxmock.com/m1/3174267-1700689-default")!,
        description: "Apifox mock host shared by AIDataInsight development clients."
    )
}

public enum PlatformKind: String, Sendable {
    case iPhone
    case iPad
    case mac
    case vision
}
