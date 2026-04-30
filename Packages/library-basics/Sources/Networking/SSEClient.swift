//
//  SSEClient.swift
//  LibraryCommon
//
//  Created by Janlor on 4/30/26.
//

import Foundation

enum SSEClientError: LocalizedError {
    case invalidResponse
    case badStatusCode(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid SSE response."
        case .badStatusCode(let statusCode):
            return "SSE request failed with status code: \(statusCode)."
        }
    }
}

public final class SSEClient: NSObject {
    public var onEvent: ((String) -> Void)?
    public var onComplete: ((Error?) -> Void)?
    
    private let request: URLRequest
    private var session: URLSession?
    private var dataTask: URLSessionDataTask?
    private var buffer = Data()
    private var hasCompleted = false
    
    public init(request: URLRequest) {
        self.request = request
    }
    
    public func start() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 300
        
        let session = URLSession(
            configuration: configuration,
            delegate: self,
            delegateQueue: nil
        )
        let dataTask = session.dataTask(with: request)
        
        self.session = session
        self.dataTask = dataTask
        dataTask.resume()
    }
    
    public func cancel() {
        dataTask?.cancel()
        finish(nil)
    }
    
    private func finish(_ error: Error?) {
        guard !hasCompleted else { return }
        hasCompleted = true
        dataTask = nil
        session?.invalidateAndCancel()
        session = nil
        onComplete?(error)
    }
    
    private func consumeEventsIfNeeded() {
        let separator = Data("\n\n".utf8)
        
        while let range = buffer.range(of: separator) {
            let packet = buffer.subdata(in: buffer.startIndex..<range.lowerBound)
            buffer.removeSubrange(buffer.startIndex..<range.upperBound)
            handleEvent(packet)
        }
    }
    
    private func handleEvent(_ data: Data) {
        guard let text = String(data: data, encoding: .utf8) else { return }
        
        let payload = text
            .split(separator: "\n")
            .compactMap { line -> String? in
                guard line.hasPrefix("data:") else { return nil }
                return String(line.dropFirst(5)).trimmingCharacters(in: .whitespaces)
            }
            .joined(separator: "\n")
        
        guard !payload.isEmpty else { return }
        onEvent?(payload)
    }
}

extension SSEClient: URLSessionDataDelegate {
    public func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        guard let httpResponse = response as? HTTPURLResponse else {
            completionHandler(.cancel)
            finish(SSEClientError.invalidResponse)
            return
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            completionHandler(.cancel)
            finish(SSEClientError.badStatusCode(httpResponse.statusCode))
            return
        }
        
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard !hasCompleted else { return }
        buffer.append(data)
        consumeEventsIfNeeded()
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error as? URLError, error.code == .cancelled {
            finish(nil)
            return
        }
        
        if !buffer.isEmpty {
            handleEvent(buffer)
            buffer.removeAll(keepingCapacity: false)
        }
        
        finish(error)
    }
}
