//
//  DownloadNetwork.swift
//  LibraryCommon
//
//  Created by Janlor on 6/14/24.
//

import Foundation
import Moya

public struct DownloadNetwork {
    static let provider = MoyaProvider<DownloadApi>(plugins: [
        NetworkAuthPlugin()
    ])

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
        // 下载
        provider.request(target) { progress in
//            print(progress.progress)
            progressBlock?(progress.progress)
        } completion: { result in
            switch result {
            case .success:
                // 下载成功后，文件已保存到指定的目标路径
                completion(.success(destinationPath))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
