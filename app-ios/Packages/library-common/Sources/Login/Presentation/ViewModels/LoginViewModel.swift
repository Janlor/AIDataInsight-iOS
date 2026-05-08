//
//  LoginViewModel.swift
//  LibraryCommon
//
//  Created by OpenAI on 2025/2/14.
//

import Foundation
import Router
import AccountProtocol

@MainActor
final class LoginViewModel {
    private let repository: LoginRepository
    private let accountService: AccountSessionStore?

    var onLoadingStateChange: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    var onLoginSuccess: (() -> Void)?

    private(set) var isLoading = false {
        didSet {
            onLoadingStateChange?(isLoading)
        }
    }

    init(
        repository: LoginRepository = DefaultLoginRepository(),
        accountService: AccountSessionStore? = Router.perform(key: AccountSessionStore.self)
    ) {
        self.repository = repository
        self.accountService = accountService
    }

    func login(username: String, password: String) async {
        guard !isLoading else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let oauth = try await repository.login(username: username, password: password)
            accountService?.update(account: oauth)
            NotificationCenter.default.post(name: .authSucceed, object: nil)
            onLoginSuccess?()
        } catch {
            onError?(error.localizedDescription)
        }
    }
}
