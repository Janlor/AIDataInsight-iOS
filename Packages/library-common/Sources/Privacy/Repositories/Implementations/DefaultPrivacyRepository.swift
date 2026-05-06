//
//  DefaultPrivacyRepository.swift
//  LibraryCommon
//
//  Created by OpenAI on 2025/2/14.
//

import Foundation

struct DefaultPrivacyRepository: PrivacyRepository {
    func isAgreedAllPolicyAgreement() -> Bool {
        PolicyManager.isAgreedAllPolicyAgreement()
    }

    func saveLatestAgreement() {
        PolicyManager.saveAgreedVersionDict(PolicyManager.latestVersionDict())
    }

    func privacyPolicyURL() -> String {
        PolicyManager.privacyPolicyURL
    }
}
