package com.aidatainsight.android.core.account.user

import com.aidatainsight.android.core.model.account.AccountUser

interface AccountRemoteService {
    suspend fun getUserInfo(): Result<AccountUser>
}
