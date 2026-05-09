package com.aidatainsight.android.core.account.auth

import com.aidatainsight.android.core.account.session.AccountSessionStore
import com.aidatainsight.android.core.network.auth.NetworkCredentialProvider

class AccountNetworkCredentialProvider(
    private val sessionStore: AccountSessionStore,
) : NetworkCredentialProvider {
    override val accessToken: String?
        get() = sessionStore.accessToken

    override val refreshToken: String?
        get() = sessionStore.refreshToken

    override val orgId: Int?
        get() = sessionStore.orgId
}

