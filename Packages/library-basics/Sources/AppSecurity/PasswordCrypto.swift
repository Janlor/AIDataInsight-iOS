//
//  File.swift
//  LibraryBasics
//
//  Created by Janlor on 2026/1/12.
//

import Foundation

public enum PasswordCrypto {
    public static func encrypt(_ plain: String) -> String? {
        encryptString(string: plain, publicKeyPEM: AppRSA.publicKey)
    }
}
