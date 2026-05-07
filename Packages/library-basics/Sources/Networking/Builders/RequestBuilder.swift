//
//  RequestBuilder.swift
//  LibraryBasics
//
//  Created by OpenAI on 2025/2/14.
//

import Foundation

public enum RequestBuilderError: LocalizedError {
    case invalidURL
    case unsupportedTask(String)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid request URL"
        case .unsupportedTask(let taskDescription):
            return "Unsupported task for URLSession migration: \(taskDescription)"
        }
    }
}

public struct RequestBuilder {
    public init() {}

    public func buildRequest(from target: RequestDescriptor) throws -> URLRequest {
        let url = try buildURL(from: target)
        var request = URLRequest(url: url)
        request.httpMethod = target.method.rawValue
        request.allHTTPHeaderFields = target.headers

        switch target.task {
        case .requestPlain:
            return request

        case .requestData(let data):
            request.httpBody = data
            return request

        case .requestParameters(let parameters, let encoding):
            return try encoding.encode(request, with: parameters)

        case .requestCompositeData(let bodyData, let urlParameters):
            request.httpBody = bodyData
            return try URLEncoding.queryString.encode(request, with: urlParameters)

        case .requestCompositeParameters(let bodyParameters, let bodyEncoding, let urlParameters):
            let urlEncodedRequest = try URLEncoding.queryString.encode(request, with: urlParameters)
            return try bodyEncoding.encode(urlEncodedRequest, with: bodyParameters)

        case .requestJSONEncodable(let encodable):
            request.httpBody = try JSONEncoder().encode(AnyEncodable(encodable))
            if request.value(forHTTPHeaderField: ContentType.key) == nil {
                request.setValue(ContentType.applicationJson.rawValue, forHTTPHeaderField: ContentType.key)
            }
            return request

        case .requestCustomJSONEncodable(let encodable, let encoder):
            request.httpBody = try encoder.encode(AnyEncodable(encodable))
            if request.value(forHTTPHeaderField: ContentType.key) == nil {
                request.setValue(ContentType.applicationJson.rawValue, forHTTPHeaderField: ContentType.key)
            }
            return request

        case .downloadParameters(let parameters, let encoding, _):
            return try encoding.encode(request, with: parameters)

        case .uploadFile:
            throw RequestBuilderError.unsupportedTask("uploadFile")
        case .uploadMultipart:
            throw RequestBuilderError.unsupportedTask("uploadMultipart")
        case .uploadCompositeMultipart:
            throw RequestBuilderError.unsupportedTask("uploadCompositeMultipart")
        case .downloadDestination:
            throw RequestBuilderError.unsupportedTask("downloadDestination")
        case .uploadMultipartFormData(_):
            throw RequestBuilderError.unsupportedTask("uploadMultipartFormData")
        case .uploadCompositeMultipartFormData(_, urlParameters: let urlParameters):
            throw RequestBuilderError.unsupportedTask("uploadCompositeMultipartFormData = \(urlParameters)")
        }
    }
}

private extension RequestBuilder {
    func buildURL(from target: RequestDescriptor) throws -> URL {
        if target.path.isEmpty {
            return target.baseURL
        }

        let trimmedPath = target.path.hasPrefix("/") ? String(target.path.dropFirst()) : target.path
        let url = target.baseURL.appendingPathComponent(trimmedPath)

        guard URLComponents(url: url, resolvingAgainstBaseURL: false) != nil else {
            throw RequestBuilderError.invalidURL
        }

        return url
    }
}

private struct AnyEncodable: Encodable {
    private let encodeImpl: (Encoder) throws -> Void

    init(_ wrapped: Encodable) {
        self.encodeImpl = { encoder in
            try wrapped.encode(to: encoder)
        }
    }

    func encode(to encoder: Encoder) throws {
        try encodeImpl(encoder)
    }
}
