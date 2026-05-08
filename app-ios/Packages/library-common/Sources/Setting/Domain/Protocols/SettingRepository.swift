//
//  SettingRepository.swift
//  LibraryCommon
//
//  Created by OpenAI on 2025/2/14.
//

import Foundation

protocol SettingRepository {
    func loadSnapshot() -> SettingSnapshot
    func logout() async throws
}
