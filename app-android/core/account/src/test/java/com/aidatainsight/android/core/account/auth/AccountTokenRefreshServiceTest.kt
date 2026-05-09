package com.aidatainsight.android.core.account.auth

import com.aidatainsight.android.core.account.session.AccountSessionStore
import com.aidatainsight.android.core.model.account.AccountSession
import com.aidatainsight.android.core.network.model.OAuthModel
import com.aidatainsight.android.core.network.service.AuthRemoteService
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class AccountTokenRefreshServiceTest {
    @Test
    fun refreshToken_updatesSessionStore() = kotlinx.coroutines.runBlocking {
        val store = FakeAccountSessionStore(
            AccountSession(
                accessToken = "old-access",
                refreshToken = "refresh-token",
                orgId = 1,
                username = "demo",
            ),
        )
        val remote = FakeAuthRemoteService(
            refreshModel = OAuthModel(accessToken = "new-access"),
        )
        val service = AccountTokenRefreshService(store) { remote }

        val refreshed = service.refreshToken("refresh-token")

        assertTrue(refreshed)
        assertEquals("refresh-token", remote.receivedRefreshToken)
        assertEquals("new-access", store.session?.accessToken)
        assertEquals("refresh-token", store.session?.refreshToken)
        assertEquals(1, store.session?.orgId)
        assertEquals("demo", store.session?.username)
    }
}

private class FakeAccountSessionStore(
    var session: AccountSession?,
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

private class FakeAuthRemoteService(
    private val refreshModel: OAuthModel,
) : AuthRemoteService {
    var receivedRefreshToken: String? = null

    override suspend fun login(username: String, password: String): OAuthModel? = null

    override suspend fun refreshToken(refreshToken: String): OAuthModel? {
        receivedRefreshToken = refreshToken
        return refreshModel
    }

    override suspend fun logout() = Unit
}

