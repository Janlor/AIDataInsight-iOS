//
//  NetworkClient.swift
//  LibraryBasics
//
//  Created by OpenAI on 2025/2/14.
//

import Foundation

public struct NetworkClientResponse {
    public let data: Data
    public let response: HTTPURLResponse

    public init(data: Data, response: HTTPURLResponse) {
        self.data = data
        self.response = response
    }
}

public enum NetworkClientError: LocalizedError {
    case invalidHTTPResponse(URLResponse)

    public var errorDescription: String? {
        switch self {
        case .invalidHTTPResponse:
            return "The network client expected an HTTPURLResponse."
        }
    }
}

public protocol NetworkClient {
    func send(_ request: URLRequest) async throws -> NetworkClientResponse
}

public struct URLSessionNetworkClient: NetworkClient {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func send(_ request: URLRequest) async throws -> NetworkClientResponse {
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkClientError.invalidHTTPResponse(response)
        }

        return NetworkClientResponse(data: data, response: httpResponse)
    }
}
