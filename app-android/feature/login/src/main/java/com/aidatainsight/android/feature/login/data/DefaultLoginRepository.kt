package com.aidatainsight.android.feature.login.data

import com.aidatainsight.android.core.account.auth.AccountAuthService
import com.aidatainsight.android.core.account.runtime.AccountRuntime
import com.aidatainsight.android.core.model.account.AccountSession
import com.aidatainsight.android.feature.login.domain.LoginRepository

class DefaultLoginRepository(
    private val authService: AccountAuthService = AccountRuntime.graph.authService,
) : LoginRepository {
    override suspend fun login(username: String, password: String): Result<AccountSession> {
        return authService.login(username = username, password = password)
    }
}
