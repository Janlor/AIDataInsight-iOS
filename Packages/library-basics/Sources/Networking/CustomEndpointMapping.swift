//
//  CustomEndpointMapping.swift
//  Network
//
//  Created by Janlor on 2024/5/22.
//

import UIKit

/// 处理header中需要及时性的参数
public func customEndpointMapping<T: TargetType>(_ target: T) -> Endpoint {
    return Endpoint(
        url: URL(target: target).absoluteString,
        sampleResponseClosure: { .networkResponse(200, target.sampleData) },
        method: target.method,
        task: target.task,
        httpHeaderFields: target.headers
    )
}

public enum ContentType: String {
    case multipartFormData = "multipart/form-data"
    case applicationJson = "application/json"
    
    public static var key: String { "Content-Type" }
}

public let platformNoKey = "platformNo"
public let platformVersionKey = "platformVersion"
public let imeiKey = "imei"
public let imsiKey = "imsi"
public let versionKey = "version"
public let buildKey = "build"
public let deviceTypeKey = "deviceType"
public let deviceModelKey = "deviceModel"
public let deviceBrandKey = "deviceBrand"
public let channelKey = "channel"

public extension CustomTargetType {
    
    /// 默认header
    func defaultHeaders() -> [String: String]? {
        
        var headers = [String: String]()
        
        headers.merge(platformNo) { $1 }
        headers.merge(platformVersion) { $1 }
        headers.merge(imei) { $1 }
        headers.merge(imsi) { $1 }
        headers.merge(version) { $1 }
        headers.merge(build) { $1 }
        headers.merge(deviceType) { $1 }
        headers.merge(deviceModel) { $1 }
        headers.merge(deviceBrand) { $1 }
        headers.merge(channel) { $1 }
        
        if !contentType.isEmpty {
            headers.merge(contentType) { $1 }
        }
        
        return headers
    }
    
    private var contentType: [String: String] {
        let content = isUpload ?
        ContentType.multipartFormData.rawValue :
        ContentType.applicationJson.rawValue
        return [ContentType.key: content]
    }
    
    // 平台类型 e.g. @"iOS"
    private var platformNo: [String: String] {
        [platformNoKey: UIDevice.current.systemName]
    }
    
    // 平台版本号 e.g. @"14.2"
    private var platformVersion: [String: String] {
        [platformVersionKey: UIDevice.current.systemVersion]
    }
    
    private var imei: [String: String] {
        [imeiKey: UIDevice.current.identifierForVendor?.uuidString ?? " "]
    }
    
    private var imsi: [String: String] {
        [imsiKey: " "]
    }
    
    // App版本号 e.g. @"1.0.1"
    private var version: [String: String] {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return [versionKey: v ?? " "]
    }
    
    // App构建号 e.g. @"12"
    private var build: [String: String] {
        let v = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        return [buildKey: v ?? " "]
    }
    
    // 设备类型 e.g. @"iPhone", @"iPod touch"
    private var deviceType: [String: String] {
        [deviceTypeKey: UIDevice.current.model]
    }
    
    // 设备型号 e.g. @"iPhone12,3" 表示 iPhone 11 Pro
    private var deviceModel: [String: String] {
        let deviceModel = UserDefaults.standard.object(forKey: "kDeviceModel") as? String
        return [deviceModelKey: deviceModel ?? " "]
    }
    
    // 设备品牌
    private var deviceBrand: [String: String] {
        [deviceBrandKey: "Apple"]
    }
    
    // 安装渠道
    private var channel: [String: String] {
        [channelKey: Config.inferredChannel]
    }
}

private extension CustomTargetType {
    // 默认非上传请求
    var isUpload: Bool {
        switch self.task {
            case .uploadFile(_): fallthrough
            case .uploadMultipart(_): fallthrough
            case .uploadCompositeMultipart(_, _):
                return true
            default:
                return false
        }
    }
}
