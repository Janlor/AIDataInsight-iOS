//
//  DataNetwork.swift
//  LibraryBasics
//
//  Created by Janlor on 11/28/25.
//

import Foundation

public struct DataNetwork {
    static var requestData: (
        _ request: URLRequest,
        _ progress: ((Double) -> Void)?,
        _ completion: @escaping (Result<Data, Error>) -> Void
    ) -> Void = { request, progress, completion in
        URLSessionTransfer.requestData(
            request,
            progress: progress,
            completion: completion
        )
    }

    public static func downloadFile(from target: DataApi,
                                    fileName: String,
                                    progressBlock: ((Double) -> Void)? = nil,
                                    completion: @escaping (Result<URL, Error>) -> Void) {
        let destinationPath = DownloadApi.destinationPath(fileName)
        let request = URLSessionRequestFactory.request(for: target)

        requestData(
            request,
            progressBlock
        ) { result in
            switch result {
            case .success(let data):
                do {
                    try data.write(to: destinationPath)
                    completion(.success(destinationPath))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
