//
//  PrivacyRepository.swift
//  LibraryCommon
//
//  Created by OpenAI on 2025/2/14.
//

import Foundation

protocol PrivacyRepository {
    func isAgreedAllPolicyAgreement() -> Bool
    func saveLatestAgreement()
    func privacyPolicyURL() -> String
}
