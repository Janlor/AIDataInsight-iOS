//
//  String+MD5.swift
//  LibraryBasics
//
//  Created by Janlor on 4/22/26.
//

import Foundation
import CommonCrypto

extension String {
    var md5: String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))

        data.withUnsafeBytes {
            _ = CC_MD5($0.baseAddress, CC_LONG(data.count), &digest)
        }

        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
