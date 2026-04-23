//
//  DataNetwork.swift
//  LibraryCommon
//
//  Created by Janlor on 4/22/26.
//

import Foundation
import Moya

public struct DataNetwork {
    /// 服务提供者
    /// 此处可以插入全局的拦截器
    public static let provider: MoyaProvider<DataApi> = {
        // 插件数组
        var plugins: [PluginType] = [
            NetworkAuthPlugin()
        ]
        
#if DEBUG
        let loggerPlugin = NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        plugins.append(loggerPlugin)
#endif
        return MoyaProvider<DataApi>(
            endpointClosure: customEndpointMapping,
            plugins: plugins
        )
    }()
    
    public static func downloadFile(from target: DataApi,
                                    fileName: String,
                                    progressBlock: ((Double) -> Void)? = nil,
                                    completion: @escaping (Result<URL, Error>) -> Void) {
        // 提前计算文件的目标路径
        let destinationPath = DownloadApi.destinationPath(fileName)
        // 已经下载
//        if FileManager.default.fileExists(atPath: destinationPath.relativePath) {
//            completion(.success(destinationPath))
//            return
//        }

        // 下载
        provider.request(target) { progress in
            progressBlock?(progress.progress)
        } completion: { result in
            switch result {
            case .success(let response):
                do {
                    // 手动保存数据
                    try response.data.write(to: destinationPath)
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
