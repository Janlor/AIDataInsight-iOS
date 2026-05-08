package com.aidatainsight.android.feature.login.data

import com.aidatainsight.android.core.model.account.AccountSession
import com.aidatainsight.android.feature.login.domain.LoginRepository

class DefaultLoginRepository : LoginRepository {
    override suspend fun login(username: String, password: String): Result<AccountSession> {
        return Result.success(
            AccountSession(
                accessToken = "demo-access-token",
                refreshToken = "demo-refresh-token",
                username = username,
            ),
        )
    }
}
