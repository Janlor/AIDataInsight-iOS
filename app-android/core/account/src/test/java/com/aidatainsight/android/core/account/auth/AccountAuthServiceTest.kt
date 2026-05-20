package com.aidatainsight.android.core.account.auth

import com.aidatainsight.android.core.account.session.AccountSessionStore
import com.aidatainsight.android.core.account.user.AccountUserStore
import com.aidatainsight.android.core.model.account.AccountSession
import com.aidatainsight.android.core.model.account.AccountUser
import com.aidatainsight.android.core.network.model.OAuthModel
import com.aidatainsight.android.core.network.service.AuthRemoteService
import kotlinx.coroutines.runBlocking
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertTrue

class AccountAuthServiceTest {
    @Test
    fun logout_clearsSessionAndUserInfo() = runBlocking {
        val sessionStore = AuthServiceFakeAccountSessionStore(AccountSession(accessToken = "access-token"))
        val userStore = AuthServiceFakeAccountUserStore(AccountUser(username = "janlor"))
        val service = AccountAuthService(
            authRemoteService = AuthServiceFakeAuthRemoteService(),
            sessionStore = sessionStore,
            userStore = userStore,
        )

        val result = service.logout()

        assertTrue(result.isSuccess)
        assertNull(sessionStore.session)
        assertNull(userStore.user)
    }

    @Test
    fun login_persistsSessionButDoesNotInventUserInfo() = runBlocking {
        val sessionStore = AuthServiceFakeAccountSessionStore()
        val userStore = AuthServiceFakeAccountUserStore()
        val service = AccountAuthService(
            authRemoteService = AuthServiceFakeAuthRemoteService(
                loginModel = OAuthModel(accessToken = "access-token", refreshToken = "refresh-token"),
            ),
            sessionStore = sessionStore,
            userStore = userStore,
        )

        val result = service.login(username = "demo", password = "demo@123")

        assertTrue(result.isSuccess)
        assertEquals("access-token", sessionStore.session?.accessToken)
        assertEquals("demo", sessionStore.session?.username)
        assertNull(userStore.user)
    }
}

private class AuthServiceFakeAccountSessionStore(
    var session: AccountSession? = null,
) : AccountSessionStore {
    override val isLogin: Boolean
        get() = session?.accessToken.isNullOrBlank().not()

    override val accessToken: String?
        get() = session?.accessToken

    override val refreshToken: String?
        get() = session?.refreshToken

    override val orgId: Int?
        get() = session?.orgId

    override val username: String?
        get() = session?.username

    override suspend fun update(session: AccountSession) {
        this.session = session
    }

    override suspend fun remove() {
        session = null
    }

    override suspend fun currentSession(): AccountSession? = session
}

private class AuthServiceFakeAccountUserStore(
    var user: AccountUser? = null,
) : AccountUserStore {
    override suspend fun updateUser(user: AccountUser) {
        this.user = user
    }

    override suspend fun getUser(): AccountUser? = user

    override suspend fun remove() {
        user = null
    }
}

private class AuthServiceFakeAuthRemoteService(
    private val loginModel: OAuthModel? = null,
) : AuthRemoteService {
    override suspend fun login(username: String, password: String): OAuthModel? = loginModel

    override suspend fun refreshToken(refreshToken: String): OAuthModel? = null

    override suspend fun logout() = Unit
}
