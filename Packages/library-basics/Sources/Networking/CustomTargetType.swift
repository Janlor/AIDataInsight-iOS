//
//  CustomTargetType.swift
//  LibraryBasics
//
//  Created by Janlor on 2024/5/22.
//

import Foundation

/// 业务请求必须要实现的协议
/// parameters 属于必须实现，其它内容有默认实现
public protocol CustomTargetType: TargetType {
    
    /// 实现CustomTargetType协议的类型，如果实现该协议则能够走默认的请求任务类型
    /// 否则需要自己实现Task
    /// 默认Task请求类型： Task.requestParameters(parameters: target.toParameters(), encoding: JSONEncoding.default)
    var parameters: [String: Any] { get }
    
}

public extension CustomTargetType {
    
    /// 默认的host
    var baseURL: URL { NetworkServer.baseURL }
    
    /// 默认的path
    var path: String { "" }
    
    /// 默认的HttpMethod
    var method: Method { Method.post }
    
    /// 默认的测试用例
    var sampleData: Data { Data() }
    
    var task: Task { defalutTask() }
    
    /// 默认的header
    var headers: [String: String]? { defaultHeaders() }
}

public extension CustomTargetType {
    
    /// 默认的请求任务类型
    func defalutTask() -> Task {
        let encoding: ParameterEncoding
        
        switch self.method {
            case .get:
                encoding = URLEncoding.queryString
            default:
                encoding = JSONEncoding.prettyPrinted
        }
        
        if parameters.isEmpty {
            return Task.requestPlain
        } else {
            return Task.requestParameters(parameters: parameters, encoding: encoding)
        }
    }
    
    /// 普通的请求类型
    func requestParameters(encoding: ParameterEncoding? = nil) -> Task {
        let encode = encoding ?? JSONEncoding.default
        
        if parameters.isEmpty {
            return Task.requestPlain
        } else {
            return Task.requestParameters(parameters: parameters, encoding: encode)
        }
    }
    
    /// 表单上传。文件上传请去Moya.Task中查找
    /// 关于上传中MultipartFormData的mimeType，请参考
    /// https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Basics_of_HTTP/MIME_types
    func upload(_ parts: [MultipartFormBodyPart]) -> Task {
        let multipart = MultipartFormData(parts: parts)
        
        if parameters.isEmpty {
            return .uploadMultipartFormData(multipart)
        } else {
            return .uploadCompositeMultipartFormData(multipart, urlParameters: parameters)
        }
    }

    /// 下载
    func downloadParameters(encoding: ParameterEncoding? = nil, destination: @escaping DownloadDestination) -> Task {
        let encode = encoding ?? JSONEncoding.default
        
        if parameters.isEmpty {
            return Task.downloadDestination(destination)
        } else {
            return Task.downloadParameters(parameters: parameters, encoding: encode, destination: destination)
        }
    }
}

public extension CustomTargetType {

    var cacheKey: String {
        var components: [String] = []

        // 1. path
        components.append(path)

        // 2. method
        components.append(method.rawValue)

        // 3. headers
        if let headers = headers, headers.keys.contains("Org-Id") == true {
            components.append("Org-Id=\(headers["Org-Id"])")
        } else if let orgId = NetworkDependencies.credentialProvider.orgId {
            components.append("Org-Id=\(orgId)")
        }
        
        // 4. parameters（排序后序列化）
        if !parameters.isEmpty {
            let sortedParams = parameters
                .sorted { $0.key < $1.key }
                .map { "\($0.key)=\($0.value)" }
                .joined(separator: "&")

            components.append(sortedParams)
        }

        let rawKey = components.joined(separator: "|")
        return rawKey.md5
    }
}
