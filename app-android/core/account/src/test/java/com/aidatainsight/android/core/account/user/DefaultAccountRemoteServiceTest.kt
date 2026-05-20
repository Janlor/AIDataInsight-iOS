package com.aidatainsight.android.core.account.user

import com.aidatainsight.android.core.model.account.AccountUser
import kotlinx.coroutines.runBlocking
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue
import com.aidatainsight.android.core.model.contract.AccountUser as ContractAccountUser
import com.aidatainsight.android.core.network.model.MenuItem
import com.aidatainsight.android.core.network.service.AccountRemoteService as NetworkAccountRemoteService

class DefaultAccountRemoteServiceTest {
    @Test
    fun getUserInfo_persistsReturnedAccountUser() = runBlocking {
        val userStore = FakeAccountUserStore()
        val service = DefaultAccountRemoteService(
            networkRemoteService = FakeNetworkAccountRemoteService(
                user = ContractAccountUser(
                    id = 7,
                    username = "janlor",
                    nickname = "Janlor Lee",
                    phone = "13800000000",
                ),
            ),
            userStore = userStore,
        )

        val result = service.getUserInfo()

        assertTrue(result.isSuccess)
        assertEquals("Janlor Lee", result.getOrThrow().nickname)
        assertEquals(result.getOrThrow(), userStore.user)
    }
}

private class FakeNetworkAccountRemoteService(
    private val user: ContractAccountUser?,
) : NetworkAccountRemoteService {
    override suspend fun getUserInfo(): ContractAccountUser? = user

    override suspend fun updatePassword(oldPassword: String, newPassword: String) = Unit

    override suspend fun getMenuTree(): List<MenuItem> = emptyList()
}

private class FakeAccountUserStore : AccountUserStore {
    var user: AccountUser? = null
        private set

    override suspend fun updateUser(user: AccountUser) {
        this.user = user
    }

    override suspend fun getUser(): AccountUser? = user

    override suspend fun remove() {
        user = null
    }
}
