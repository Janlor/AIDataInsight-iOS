package com.aidatainsight.android.core.account.auth

import com.aidatainsight.android.core.model.account.AccountSession
import com.aidatainsight.android.core.network.model.OAuthModel
import kotlin.test.Test
import kotlin.test.assertEquals

class AccountMappersTest {
    @Test
    fun oauthModelToAccountSession_preservesPreviousNullableFields() {
        val previous = AccountSession(
            accessToken = "old-access",
            refreshToken = "old-refresh",
            orgId = 12,
            username = "demo",
        )

        val session = OAuthModel(accessToken = "new-access")
            .toAccountSession(previous = previous)

        assertEquals("new-access", session.accessToken)
        assertEquals("old-refresh", session.refreshToken)
        assertEquals(12, session.orgId)
        assertEquals("demo", session.username)
    }
}

