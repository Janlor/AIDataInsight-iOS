//
//  NetworkExecutor.swift
//  LibraryBasics
//
//  Created by OpenAI on 2025/2/14.
//

import Foundation

public struct NetworkExecutor {
    private let requestBuilder: RequestBuilder
    private let networkClient: NetworkClient
    private let credentialProvider: NetworkCredentialProvider
    private let tokenRefreshCoordinator: TokenRefreshCoordinator
    private let sessionInvalidationHandler: SessionInvalidationHandler

    public init(
        requestBuilder: RequestBuilder = RequestBuilder(),
        networkClient: NetworkClient = NetworkDependencies.networkClient,
        credentialProvider: NetworkCredentialProvider = NetworkDependencies.credentialProvider,
        tokenRefreshCoordinator: TokenRefreshCoordinator = NetworkDependencies.tokenRefreshCoordinator,
        sessionInvalidationHandler: SessionInvalidationHandler = NetworkDependencies.sessionInvalidationHandler
    ) {
        self.requestBuilder = requestBuilder
        self.networkClient = networkClient
        self.credentialProvider = credentialProvider
        self.tokenRefreshCoordinator = tokenRefreshCoordinator
        self.sessionInvalidationHandler = sessionInvalidationHandler
    }

    public func requestData(_ target: RequestDescriptor) async throws -> Data {
        try await requestData(target, hasRetriedAfterRefresh: false)
    }

    public func request<Model: Decodable>(_ target: RequestDescriptor, as type: Model.Type) async throws -> Model {
        let data = try await requestData(target)

        do {
            return try NetworkDecoder.decode(Model.self, from: data)
        } catch {
            throw NetworkError.objectMapping(error, makeResponse(from: data, statusCode: 200, request: nil, response: nil))
        }
    }
}

private extension NetworkExecutor {
    func requestData(_ target: RequestDescriptor, hasRetriedAfterRefresh: Bool) async throws -> Data {
        let request = try requestBuilder.buildRequest(from: target)
        let result = try await networkClient.send(request)
        let response = makeResponse(
            from: result.data,
            statusCode: result.response.statusCode,
            request: request,
            response: result.response
        )

        guard (200..<400).contains(response.statusCode) else {
            throw NetworkError.statusCode(response)
        }

        let decodedResponse: ResponseModel<EmptyModel>
        do {
            decodedResponse = try NetworkDecoder.decode(ResponseModel<EmptyModel>.self, from: result.data)
        } catch {
            return result.data
        }

        guard let code = decodedResponse.code else {
            return result.data
        }

        switch code {
        case 200:
            return result.data
        case 401, 600:
            sessionInvalidationHandler.invalidateSession(message: decodedResponse.msg)
            throw NetworkError.underlying(ResponseError.server(code, decodedResponse.msg), response)
        case 402:
            guard hasRetriedAfterRefresh == false else {
                sessionInvalidationHandler.invalidateSession(message: decodedResponse.msg)
                throw NetworkError.underlying(ResponseError.server(code, decodedResponse.msg), response)
            }

            let refreshToken = credentialProvider.refreshToken
            let refreshed = try await refreshTokenIfNeeded(refreshToken)
            guard refreshed else {
                sessionInvalidationHandler.invalidateSession(message: decodedResponse.msg)
                throw NetworkError.underlying(ResponseError.server(code, decodedResponse.msg), response)
            }
            return try await requestData(target, hasRetriedAfterRefresh: true)
        default:
            throw NetworkError.underlying(ResponseError.server(code, decodedResponse.msg), response)
        }
    }

    func refreshTokenIfNeeded(_ refreshToken: String?) async throws -> Bool {
        try await tokenRefreshCoordinator.refreshToken(refreshToken)
    }

    func makeResponse(
        from data: Data,
        statusCode: Int,
        request: URLRequest?,
        response: HTTPURLResponse?
    ) -> NetworkResponse {
        NetworkResponse(statusCode: statusCode, data: data, request: request, response: response)
    }
}
