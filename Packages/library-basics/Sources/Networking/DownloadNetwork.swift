//
//  DownloadNetwork.swift
//  LibraryBasics
//
//  Created by Janlor on 6/14/24.
//

import Foundation

public struct DownloadNetwork {
    /// 下载后自动保存
    public static func downloadFile(from target: DownloadApi,
                                    fileName: String,
                                    progressBlock: ((Double) -> Void)? = nil,
                                    completion: @escaping (Result<URL, Error>) -> Void) {
        // 提前计算文件的目标路径
        let destinationPath = DownloadApi.destinationPath(fileName)
        // 已经下载
        if FileManager.default.fileExists(atPath: destinationPath.relativePath) {
            completion(.success(destinationPath))
            return
        }

        let request = URLSessionRequestFactory.request(for: target)
        URLSessionTransfer.downloadFile(
            request,
            destinationURL: destinationPath,
            progress: progressBlock,
            completion: completion
        )
    }
}
