//
//  PrivacyPolicyViewModel.swift
//  LibraryCommon
//
//  Created by OpenAI on 2025/2/14.
//

import Foundation
import Environment

final class PrivacyPolicyViewModel {
    private let repository: PrivacyRepository
    private(set) var hasShownPolicy = false

    init(repository: PrivacyRepository = DefaultPrivacyRepository()) {
        self.repository = repository
    }

    func isAgreedAllPolicyAgreement() -> Bool {
        repository.isAgreedAllPolicyAgreement()
    }

    func shouldShowPolicyAgreement() -> Bool {
        guard !hasShownPolicy else { return false }
        hasShownPolicy = true
        return !repository.isAgreedAllPolicyAgreement()
    }

    func makeAlertContent() -> PrivacyPolicyAlertContent {
        let title: String
        switch CommonTarget.target {
        default:
            title = NSLocalizedString("欢迎使用AI数据分析助手", bundle: .module, comment: "")
        }

        return PrivacyPolicyAlertContent(
            title: title,
            content: NSLocalizedString("PrivacyPolicyContent", bundle: .module, comment: ""),
            message: NSLocalizedString("PrivacyPolicyMessage", bundle: .module, comment: ""),
            linkTexts: [
                NSLocalizedString("《隐私政策》", bundle: .module, comment: ""): repository.privacyPolicyURL()
            ],
            cancelTitle: NSLocalizedString("取消", bundle: .module, comment: ""),
            confirmTitle: NSLocalizedString("同意并继续", bundle: .module, comment: "")
        )
    }

    func agreeToLatestPolicy() {
        repository.saveLatestAgreement()
        NotificationCenter.default.post(name: .didAgreedAllPolicyAgreement, object: nil)
    }

    func privacyPolicyURL() -> String {
        repository.privacyPolicyURL()
    }
}
