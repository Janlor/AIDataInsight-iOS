package com.aidatainsight.android.core.account.auth

import com.aidatainsight.android.core.account.session.AccountSessionStore
import com.aidatainsight.android.core.account.user.AccountUserStore
import com.aidatainsight.android.core.model.account.AccountSession
import com.aidatainsight.android.core.network.service.AuthRemoteService

class AccountAuthService(
    private val authRemoteService: AuthRemoteService,
    private val sessionStore: AccountSessionStore,
    private val userStore: AccountUserStore,
) {
    suspend fun login(username: String, password: String): Result<AccountSession> {
        return runCatching {
            val model = authRemoteService.login(username, password)
                ?: error("登录响应为空。")
            val session = model.toAccountSession(username = username)
            sessionStore.update(session)
            session
        }
    }

    suspend fun logout(): Result<Unit> {
        return runCatching {
            authRemoteService.logout()
            sessionStore.remove()
            userStore.remove()
        }
    }
}
