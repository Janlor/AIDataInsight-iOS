package com.aidatainsight.android.core.account.auth

import com.aidatainsight.android.core.account.session.AccountSessionStore
import com.aidatainsight.android.core.account.session.SharedPreferencesAccountSessionStore
import com.aidatainsight.android.core.account.user.AccountUserStore
import com.aidatainsight.android.core.account.user.SharedPreferencesAccountUserStore
import com.aidatainsight.android.core.network.auth.SessionInvalidationHandler

class AccountSessionInvalidationHandler(
    private val sessionStore: AccountSessionStore,
    private val userStore: AccountUserStore,
) : SessionInvalidationHandler {
    var lastInvalidationMessage: String? = null
        private set

    override fun invalidateSession(message: String?) {
        lastInvalidationMessage = message
        (sessionStore as? SharedPreferencesAccountSessionStore)?.removeImmediately()
        (userStore as? SharedPreferencesAccountUserStore)?.removeImmediately()
    }
}

