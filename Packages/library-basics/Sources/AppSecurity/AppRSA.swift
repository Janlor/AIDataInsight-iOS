//
//  AppRSA.swift
//  LibraryCommon
//
//  Created by Janlor on 4/22/26.
//

import Foundation
import Security

struct AppRSA {
   static var publicKey: String {
       ""
   }
}

func encryptString(string: String, publicKeyPEM: String) -> String? {
    // 1. 去除 PEM 格式中的头部和尾部标签，并清理换行符
    let cleanPEM = publicKeyPEM
        .replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
        .replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
        .replacingOccurrences(of: "\n", with: "")
    
    // 2. 将清理后的 PEM 公钥字符串解码为 Data 对象
    guard let publicKeyData = Data(base64Encoded: cleanPEM) else {
//        print("Failed to decode public key PEM")
        return nil
    }
    
    // 3. 创建 SecKey 对象
    // 动态计算公钥的大小（以位为单位）
    let keySizeInBits = publicKeyData.count * 8
    let attributes: [String: Any] = [
        kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
        kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
        kSecAttrKeySizeInBits as String: keySizeInBits
    ]
    
    var error: Unmanaged<CFError>?
    guard let publicKey = SecKeyCreateWithData(publicKeyData as CFData, attributes as CFDictionary, &error) else {
//        print("Failed to create public key from PEM: \(String(describing: error?.takeRetainedValue()))")
        return nil
    }

    // 4. 将字符串转换为 Data 对象
    guard let stringData = string.data(using: .utf8) else {
//        print("Failed to convert string to data")
        return nil
    }

    // 5. 使用公钥加密密码数据，确保使用 PKCS#1 填充方式
    guard let encryptedData = SecKeyCreateEncryptedData(publicKey, .rsaEncryptionPKCS1, stringData as CFData, &error) else {
//        print("Failed to encrypt string: \(String(describing: error?.takeRetainedValue()))")
        return nil
    }

    // 6. 将加密后的数据进行 Base64 编码
    let base64Encoded = (encryptedData as Data).base64EncodedString()
    return base64Encoded
}
