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
        case transport(message: String)
        case sessionInvalid(SessionInvalidationReason)
    }

    public let kind: Kind
    public let traceID: String?
    public let transactionID: String?

    public init(kind: Kind, traceID: String? = nil, transactionID: String? = nil) {
        self.kind = kind
        self.traceID = traceID
        self.transactionID = transactionID
    }
}
