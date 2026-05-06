//
//  URLSessionTransfer.swift
//  LibraryBasics
//
//  Created by Codex on 2025/9/18.
//

import Foundation

internal enum URLSessionTransfer {
    static func requestData(
        _ request: URLRequest,
        progress: ((Double) -> Void)? = nil,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        let delegate = DataRequestDelegate(progress: progress, completion: completion)
        let session = URLSession(
            configuration: .default,
            delegate: delegate,
            delegateQueue: nil
        )
        delegate.session = session
        let task = session.dataTask(with: request)
        delegate.task = task
        task.resume()
    }

    static func downloadFile(
        _ request: URLRequest,
        destinationURL: URL,
        progress: ((Double) -> Void)? = nil,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        let delegate = DownloadRequestDelegate(
            destinationURL: destinationURL,
            progress: progress,
            completion: completion
        )
        let session = URLSession(
            configuration: .default,
            delegate: delegate,
            delegateQueue: nil
        )
        delegate.session = session
        let task = session.downloadTask(with: request)
        delegate.task = task
        task.resume()
    }
}

internal enum URLSessionRequestFactory {
    static func request(for target: DataApi) -> URLRequest {
        let url = target.path.isEmpty ? target.baseURL : target.baseURL.appendingPathComponent(target.path)
        var request = URLRequest(url: url)
        request.httpMethod = target.method.rawValue
        request.allHTTPHeaderFields = target.headers
        applyNetworkAuthHeaders(to: &request)

        switch target.task {
        case .requestData(let data):
            request.httpBody = data
        default:
            break
        }

        return request
    }

    static func request(for target: DownloadApi) -> URLRequest {
        let url = target.path.isEmpty ? target.baseURL : target.baseURL.appendingPathComponent(target.path)
        var request = URLRequest(url: url)
        request.httpMethod = target.method.rawValue
        request.allHTTPHeaderFields = target.headers
        applyNetworkAuthHeaders(to: &request)
        return request
    }

    private static func applyNetworkAuthHeaders(to request: inout URLRequest) {
        if let token = NetworkDependencies.credentialProvider.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let orgId = NetworkDependencies.credentialProvider.orgId,
           request.value(forHTTPHeaderField: "Org-Id") == nil {
            request.setValue("\(orgId)", forHTTPHeaderField: "Org-Id")
        }
    }
}

private final class DataRequestDelegate: NSObject, URLSessionDataDelegate {
    weak var session: URLSession?
    weak var task: URLSessionTask?

    private let progress: ((Double) -> Void)?
    private let completion: (Result<Data, Error>) -> Void
    private var expectedContentLength: Int64 = NSURLSessionTransferSizeUnknown
    private var receivedData = Data()
    private var hasCompleted = false

    init(
        progress: ((Double) -> Void)?,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        self.progress = progress
        self.completion = completion
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse) async -> URLSession.ResponseDisposition {
        expectedContentLength = response.expectedContentLength
        progress?(0)
        return .allow
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        receivedData.append(data)

        guard expectedContentLength > 0 else { return }
        let percent = Double(receivedData.count) / Double(expectedContentLength)
        progress?(min(max(percent, 0), 1))
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard hasCompleted == false else { return }
        hasCompleted = true

        if let error {
            completion(.failure(error))
        } else {
            progress?(1)
            completion(.success(receivedData))
        }

        finish()
    }

    private func finish() {
        task = nil
        session?.finishTasksAndInvalidate()
        session = nil
    }
}

private final class DownloadRequestDelegate: NSObject, URLSessionDownloadDelegate {
    weak var session: URLSession?
    weak var task: URLSessionTask?

    private let destinationURL: URL
    private let progress: ((Double) -> Void)?
    private let completion: (Result<URL, Error>) -> Void
    private var hasCompleted = false

    init(
        destinationURL: URL,
        progress: ((Double) -> Void)?,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        self.destinationURL = destinationURL
        self.progress = progress
        self.completion = completion
    }

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        guard totalBytesExpectedToWrite > 0 else { return }
        let percent = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        progress?(min(max(percent, 0), 1))
    }

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        guard hasCompleted == false else { return }

        do {
            let directory = destinationURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true,
                attributes: nil
            )
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.moveItem(at: location, to: destinationURL)
            progress?(1)
            complete(.success(destinationURL))
        } catch {
            complete(.failure(error))
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error {
            complete(.failure(error))
        }
    }

    private func complete(_ result: Result<URL, Error>) {
        guard hasCompleted == false else { return }
        hasCompleted = true
        completion(result)
        finish()
    }

    private func finish() {
        task = nil
        session?.finishTasksAndInvalidate()
        session = nil
    }
}
