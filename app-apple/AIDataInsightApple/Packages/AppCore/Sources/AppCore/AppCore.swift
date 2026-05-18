import Foundation

public enum AppEnvironment: String, CaseIterable, Sendable {
    case mock
    case local
    case dev
    case test
    case pre
    case prod
}

public enum PlatformKind: String, Sendable {
    case iPhone
    case iPad
    case mac
    case vision
}

public enum RouteIntent: Equatable, Sendable {
    case login
    case workspace
    case privacy
    case settings
}

public enum SessionInvalidationReason: Equatable, Sendable {
    case unauthorized
    case refreshFailed
    case logout
}

public struct AppError: Error, Equatable, Sendable {
    public enum Kind: Equatable, Sendable {
        case unknown
        case dataFormat
        case server(code: Int, message: String)
        case sessionInvalid(SessionInvalidationReason)
    }

    public let kind: Kind
    public let traceID: String?

    public init(kind: Kind, traceID: String? = nil) {
        self.kind = kind
        self.traceID = traceID
    }
}
