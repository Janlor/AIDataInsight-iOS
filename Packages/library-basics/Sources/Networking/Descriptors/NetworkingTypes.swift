//
//  NetworkingTypes.swift
//  LibraryBasics
//
//  Created by Janlor on 2024/5/22.
//

import Foundation

public protocol Cancellable {
    var isCancelled: Bool { get }
    func cancel()
}

public struct NetworkResponse: Sendable {
    public let statusCode: Int
    public let data: Data
    public let request: URLRequest?
    public let response: HTTPURLResponse?

    public init(statusCode: Int, data: Data, request: URLRequest?, response: HTTPURLResponse?) {
        self.statusCode = statusCode
        self.data = data
        self.request = request
        self.response = response
    }
}

public enum NetworkError: Error {
    case imageMapping(NetworkResponse)
    case jsonMapping(NetworkResponse)
    case stringMapping(NetworkResponse)
    case objectMapping(Error, NetworkResponse)
    case encodableMapping(Error)
    case statusCode(NetworkResponse)
    case underlying(Error, NetworkResponse?)
    case requestMapping(String)
    case parameterEncoding(Error)
}

public protocol TargetType {
    var baseURL: URL { get }
    var path: String { get }
    var method: Method { get }
    var sampleData: Data { get }
    var task: Task { get }
    var headers: [String: String]? { get }
}

public enum Method: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case head = "HEAD"
}

public protocol ParameterEncoding {
    func encode(_ urlRequest: URLRequest, with parameters: [String: Any]?) throws -> URLRequest
}

public struct JSONEncoding: ParameterEncoding {
    public enum Options {
        case `default`
        case prettyPrinted

        fileprivate var writingOptions: JSONSerialization.WritingOptions {
            switch self {
            case .default:
                return []
            case .prettyPrinted:
                return [.prettyPrinted]
            }
        }
    }

    public static let `default` = JSONEncoding(options: .default)
    public static let prettyPrinted = JSONEncoding(options: .prettyPrinted)

    private let options: Options

    public init(options: Options) {
        self.options = options
    }

    public func encode(_ urlRequest: URLRequest, with parameters: [String: Any]?) throws -> URLRequest {
        var request = urlRequest
        guard let parameters else { return request }

        request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: options.writingOptions)
        if request.value(forHTTPHeaderField: ContentType.key) == nil {
            request.setValue(ContentType.applicationJson.rawValue, forHTTPHeaderField: ContentType.key)
        }
        return request
    }
}

public struct URLEncoding: ParameterEncoding {
    public enum Destination {
        case methodDependent
        case queryString
    }

    public static let `default` = URLEncoding(destination: .methodDependent)
    public static let queryString = URLEncoding(destination: .queryString)

    private let destination: Destination

    public init(destination: Destination) {
        self.destination = destination
    }

    public func encode(_ urlRequest: URLRequest, with parameters: [String: Any]?) throws -> URLRequest {
        var request = urlRequest
        guard let parameters, parameters.isEmpty == false else { return request }

        switch destinationTarget(for: request) {
        case .queryString:
            guard let url = request.url else { return request }
            guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                throw NetworkError.requestMapping(url.absoluteString)
            }

            let existingItems = components.queryItems ?? []
            components.queryItems = existingItems + parameters
                .sorted(by: { $0.key < $1.key })
                .map { URLQueryItem(name: $0.key, value: "\($0.value)") }

            request.url = components.url
            return request

        case .httpBody:
            let query = parameters
                .sorted(by: { $0.key < $1.key })
                .map { "\($0.key)=\($0.value)" }
                .joined(separator: "&")
            request.httpBody = query.data(using: .utf8)
            if request.value(forHTTPHeaderField: ContentType.key) == nil {
                request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: ContentType.key)
            }
            return request
        }
    }

    private func destinationTarget(for request: URLRequest) -> DestinationTarget {
        switch destination {
        case .queryString:
            return .queryString
        case .methodDependent:
            let method = request.httpMethod?.uppercased()
            return method == Method.get.rawValue || method == Method.head.rawValue ? .queryString : .httpBody
        }
    }

    private enum DestinationTarget {
        case queryString
        case httpBody
    }
}

public struct MultipartFormBodyPart {
    public enum Provider {
        case data(Data)
        case file(URL)
    }

    public let provider: Provider
    public let name: String
    public let fileName: String?
    public let mimeType: String?

    public init(provider: Provider, name: String, fileName: String?, mimeType: String?) {
        self.provider = provider
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
    }
}

public struct MultipartFormData {
    public let parts: [MultipartFormBodyPart]

    public init(parts: [MultipartFormBodyPart]) {
        self.parts = parts
    }
}

public struct DownloadOptions: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let removePreviousFile = DownloadOptions(rawValue: 1 << 0)
    public static let createIntermediateDirectories = DownloadOptions(rawValue: 1 << 1)
}

public typealias DownloadDestination = (URL, HTTPURLResponse) -> (destinationURL: URL, options: DownloadOptions)

public enum Task {
    case requestPlain
    case requestData(Data)
    case requestParameters(parameters: [String: Any], encoding: ParameterEncoding)
    case requestCompositeData(bodyData: Data, urlParameters: [String: Any])
    case requestCompositeParameters(bodyParameters: [String: Any], bodyEncoding: ParameterEncoding, urlParameters: [String: Any])
    case requestJSONEncodable(any Encodable)
    case requestCustomJSONEncodable(any Encodable, encoder: JSONEncoder)
    case uploadFile(URL)
    case uploadMultipart([MultipartFormBodyPart])
    case uploadCompositeMultipart([MultipartFormBodyPart], urlParameters: [String: Any])
    case uploadMultipartFormData(MultipartFormData)
    case uploadCompositeMultipartFormData(MultipartFormData, urlParameters: [String: Any])
    case downloadDestination(DownloadDestination)
    case downloadParameters(parameters: [String: Any], encoding: ParameterEncoding, destination: DownloadDestination)
}
