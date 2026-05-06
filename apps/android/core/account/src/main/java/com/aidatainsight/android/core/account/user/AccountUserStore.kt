package com.aidatainsight.android.core.account.user

import com.aidatainsight.android.core.model.account.AccountUser

interface AccountUserStore {
    suspend fun updateUser(user: AccountUser)
    suspend fun getUser(): AccountUser?
}
