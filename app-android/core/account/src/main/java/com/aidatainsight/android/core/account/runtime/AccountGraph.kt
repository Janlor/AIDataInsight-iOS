package com.aidatainsight.android.core.account.runtime

import com.aidatainsight.android.core.account.auth.AccountAuthService
import com.aidatainsight.android.core.account.session.AccountSessionStore
import com.aidatainsight.android.core.account.user.AccountRemoteService
import com.aidatainsight.android.core.account.user.AccountUserStore

data class AccountGraph(
    val sessionStore: AccountSessionStore,
    val userStore: AccountUserStore,
    val authService: AccountAuthService,
    val accountRemoteService: AccountRemoteService,
)

