package com.aidatainsight.android.core.account.session

import com.aidatainsight.android.core.model.account.AccountSession

interface AccountSessionStore {
    val isLogin: Boolean
    val accessToken: String?
    val refreshToken: String?
    val orgId: Int?
    val username: String?

    suspend fun update(session: AccountSession)
    suspend fun remove()
    suspend fun currentSession(): AccountSession?
}
