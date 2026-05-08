//
//  LoginRepository.swift
//  LibraryCommon
//
//  Created by OpenAI on 2025/2/14.
//

import Foundation

protocol LoginRepository {
    func login(username: String, password: String) async throws -> OAuthModel
}
