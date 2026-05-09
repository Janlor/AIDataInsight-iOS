package com.aidatainsight.android.core.account.auth

import com.aidatainsight.android.core.account.session.AccountSessionStore
import com.aidatainsight.android.core.network.auth.TokenRefreshService
import com.aidatainsight.android.core.network.service.AuthRemoteService

class AccountTokenRefreshService(
    private val sessionStore: AccountSessionStore,
    private val authRemoteServiceProvider: () -> AuthRemoteService,
) : TokenRefreshService {
    override suspend fun refreshToken(token: String): Boolean {
        val previous = sessionStore.currentSession()
        val model = authRemoteServiceProvider().refreshToken(token) ?: return false
        val refreshedSession = model.toAccountSession(previous = previous)
        if (refreshedSession.accessToken.isNullOrBlank()) return false
        sessionStore.update(refreshedSession)
        return true
    }
}

