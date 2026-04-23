//
//  CryptoHelper.swift
//  LibraryBasics
//
//  Created by Janlor on 4/22/26.
//

import CryptoKit
import Foundation

enum CryptoHelper {

    /// AES-GCM 加密
    static func encrypt(_ data: Data, keyData: Data) throws -> Data {
        let key = SymmetricKey(data: keyData)
        let sealed = try AES.GCM.seal(data, using: key)
        return sealed.combined!
    }

    /// AES-GCM 解密
    static func decrypt(_ data: Data, keyData: Data) throws -> Data {
        let key = SymmetricKey(data: keyData)
        let box = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(box, using: key)
    }
}
