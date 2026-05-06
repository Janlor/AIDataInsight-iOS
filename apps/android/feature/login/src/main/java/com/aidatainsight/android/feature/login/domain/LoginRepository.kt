package com.aidatainsight.android.feature.login.domain

import com.aidatainsight.android.core.model.account.AccountSession

interface LoginRepository {
    suspend fun login(username: String, password: String): Result<AccountSession>
}
