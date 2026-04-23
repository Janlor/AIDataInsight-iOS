//
//  File.swift
//  LibraryBasics
//
//  Created by Janlor on 4/22/26.
//

import Foundation

public enum PasswordCrypto {
    public static func encrypt(_ plain: String) -> String? {
        encryptString(string: plain, publicKeyPEM: AppRSA.publicKey)
    }
}
