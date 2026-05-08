//
//  DefaultLoginRepository.swift
//  LibraryCommon
//
//  Created by OpenAI on 2025/2/14.
//

import Foundation
import Networking
import AppSecurity

struct DefaultLoginRepository: LoginRepository {
    func login(username: String, password: String) async throws -> OAuthModel {
        guard let encryptedPassword = PasswordCrypto.encrypt(password) else {
            throw NSError(
                domain: "DefaultLoginRepository.login",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("密码加密失败", bundle: .module, comment: "")]
            )
        }

        let target = OAuthApi.login(username, encryptedPassword)
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<OAuthModel, Error>) in
            ResponseModel<OAuthModel>.requestable(target) { response, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let oauth = response?.data else {
                    let error = NSError(
                        domain: "DefaultLoginRepository.login",
                        code: 2,
                        userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("未知错误", bundle: .module, comment: "")]
                    )
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(returning: oauth)
            }
        }
    }
}
