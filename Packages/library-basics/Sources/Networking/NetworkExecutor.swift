//
//  NetworkExecutor.swift
//  LibraryBasics
//
//  Created by OpenAI on 2025/2/14.
//

import Foundation
import Moya

public struct NetworkExecutor {
    private let requestBuilder: RequestBuilder
    private let networkClient: NetworkClient
    private let credentialProvider: NetworkCredentialProvider
    private let tokenRefreshService: TokenRefreshService
    private let sessionInvalidationHandler: SessionInvalidationHandler

    public init(
        requestBuilder: RequestBuilder = RequestBuilder(),
        networkClient: NetworkClient = URLSessionNetworkClient(),
        credentialProvider: NetworkCredentialProvider = NetworkDependencies.credentialProvider,
        tokenRefreshService: TokenRefreshService = NetworkDependencies.tokenRefreshService,
        sessionInvalidationHandler: SessionInvalidationHandler = NetworkDependencies.sessionInvalidationHandler
    ) {
        self.requestBuilder = requestBuilder
        self.networkClient = networkClient
        self.credentialProvider = credentialProvider
        self.tokenRefreshService = tokenRefreshService
        self.sessionInvalidationHandler = sessionInvalidationHandler
    }

    public func requestData(_ target: CustomTargetType) async throws -> Data {
        try await requestData(target, hasRetriedAfterRefresh: false)
    }

    public func request<Model: Decodable>(_ target: CustomTargetType, as type: Model.Type) async throws -> Model {
        let data = try await requestData(target)

        do {
            return try NetworkDecoder.decode(Model.self, from: data)
        } catch {
            throw MoyaError.objectMapping(error, makeResponse(from: data, statusCode: 200, request: nil, response: nil))
        }
    }
}

private extension NetworkExecutor {
    func requestData(_ target: CustomTargetType, hasRetriedAfterRefresh: Bool) async throws -> Data {
        let request = try requestBuilder.buildRequest(from: target)
        let result = try await networkClient.send(request)
        let response = makeResponse(
            from: result.data,
            statusCode: result.response.statusCode,
            request: request,
            response: result.response
        )

        do {
            _ = try response.filterSuccessfulStatusAndRedirectCodes()
        } catch MoyaError.statusCode {
            throw MoyaError.statusCode(response)
        } catch {
            throw MoyaError.underlying(error, response)
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
            throw MoyaError.underlying(ResponseError.server(code, decodedResponse.msg), response)
        case 402:
            guard hasRetriedAfterRefresh == false else {
                sessionInvalidationHandler.invalidateSession(message: decodedResponse.msg)
                throw MoyaError.underlying(ResponseError.server(code, decodedResponse.msg), response)
            }

            let refreshToken = credentialProvider.refreshToken
            let refreshed = try await refreshTokenIfNeeded(refreshToken)
            guard refreshed else {
                sessionInvalidationHandler.invalidateSession(message: decodedResponse.msg)
                throw MoyaError.underlying(ResponseError.server(code, decodedResponse.msg), response)
            }
            return try await requestData(target, hasRetriedAfterRefresh: true)
        default:
            throw MoyaError.underlying(ResponseError.server(code, decodedResponse.msg), response)
        }
    }

    func refreshTokenIfNeeded(_ refreshToken: String?) async throws -> Bool {
        guard let refreshToken else { return false }

        return try await withCheckedThrowingContinuation { continuation in
            _ = tokenRefreshService.refreshToken(refreshToken) { succeed, errorMessage in
                if let errorMessage, succeed == false {
                    continuation.resume(throwing: ResponseError.server(402, errorMessage))
                    return
                }
                continuation.resume(returning: succeed)
            }
        }
    }

    func makeResponse(
        from data: Data,
        statusCode: Int,
        request: URLRequest?,
        response: HTTPURLResponse?
    ) -> Moya.Response {
        Response(statusCode: statusCode, data: data, request: request, response: response)
    }
}
