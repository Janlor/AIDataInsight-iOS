//
//  UploadApi.swift
//  LibraryBasics
//
//  Created by Janlor on 6/12/24.
//

import UIKit
//import UniformTypeIdentifiers // iOS 14+ 专属
import MobileCoreServices

public enum UploadApi: RequestDescriptor {
    /// 上传图片
    /// (image图片，filename 图片名称)
    case image(UIImage, String?)
    
    /// 上传数据
    /// (数据，文件名称，mimeType)
    case data (Data, String?, String?)
    
    /// 上传本地文件
    case fileURL(URL)
    
    public var path: String {
        return "/file/upload"
    }
    
    public var parameters: [String : Any] {
        return [:]
    }
    
    public var task: Task {
        switch self {
        case .image(let image, let filename):
            let fileExtension = (filename as NSString?)?.pathExtension.lowercased() ?? "jpg"
            let mimeType: String
            let data: Data?

            switch fileExtension {
            case "png":
                mimeType = "image/png"
                data = image.pngData()
            default:
                mimeType = "image/jpeg"
                data = image.jpegData(compressionQuality: 1.0)
            }

            let finalFileName = filename ?? String(describing: Int(Date().timeIntervalSinceReferenceDate * 1000)) + ".\(fileExtension)"
            let formData = MultipartFormBodyPart(provider: .data(data ?? Data()),
                                             name: "file",
                                             fileName: finalFileName,
                                             mimeType: mimeType)
            return upload([formData])
            
        case let .data(data, filename, mimeType):
            let formdata = MultipartFormBodyPart(provider: .data(data),
                                             name: "file",
                                             fileName: filename ?? String(describing: Date().timeIntervalSinceReferenceDate * 1000),
                                             mimeType: mimeType)
            return upload([formdata])
            
        case .fileURL(let fileURL):
            let fileName = fileURL.lastPathComponent
            let mimeType = mimeTypeForPath(path: fileURL.path)
            let formData = MultipartFormBodyPart(provider: .file(fileURL), name: "file", fileName: fileName, mimeType: mimeType)
            return upload([formData])
        }
    }
    
    private func mimeTypeForPath(path: String) -> String {
        let url = URL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        
//        if #available(iOS 14.0, *) {
//            if let utType = UTType(filenameExtension: pathExtension) {
//                return utType.preferredMIMEType ?? "application/octet-stream"
//            }
//        } else {
            if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeRetainedValue() {
                if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                    return mimetype as String
                }
            }
//        }
        
        return "application/octet-stream"
    }
}
