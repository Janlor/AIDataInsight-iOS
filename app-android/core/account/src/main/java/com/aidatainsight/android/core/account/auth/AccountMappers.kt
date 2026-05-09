package com.aidatainsight.android.core.account.auth

import com.aidatainsight.android.core.model.account.AccountSession
import com.aidatainsight.android.core.model.account.AccountUser
import com.aidatainsight.android.core.network.model.OAuthModel

internal fun OAuthModel.toAccountSession(
    username: String? = null,
    previous: AccountSession? = null,
): AccountSession {
    return AccountSession(
        accessToken = accessToken ?: previous?.accessToken,
        refreshToken = refreshToken ?: previous?.refreshToken,
        orgId = orgId ?: previous?.orgId,
        username = username ?: this.username ?: previous?.username,
    )
}

internal fun com.aidatainsight.android.core.model.contract.AccountUser.toAccountUser(): AccountUser {
    return AccountUser(
        id = id,
        phone = phone,
        username = username,
        nickname = nickname,
    )
}

