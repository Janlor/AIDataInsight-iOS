import AppContracts
import AppCore
import Foundation

public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
}

public struct HTTPRequest: Sendable {
    public let path: String
    public let method: HTTPMethod

    public init(path: String, method: HTTPMethod = .get) {
        self.path = path
        self.method = method
    }
}

public protocol TokenProviding: Sendable {
    var accessToken: String? { get async }
}

public struct SSEEvent: Equatable, Sendable {
    public let data: String

    public init(data: String) {
        self.data = data
    }
}

public protocol HTTPClient: Sendable {
    func send<Payload: Decodable & Sendable>(_ request: HTTPRequest, as payloadType: Payload.Type) async throws -> APIResponseEnvelope<Payload>
}

public struct UnimplementedHTTPClient: HTTPClient {
    public init() {}

    public func send<Payload: Decodable & Sendable>(_ request: HTTPRequest, as payloadType: Payload.Type) async throws -> APIResponseEnvelope<Payload> {
        throw AppError(kind: .unknown)
    }
}
