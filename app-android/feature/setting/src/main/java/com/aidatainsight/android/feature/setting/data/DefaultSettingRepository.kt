package com.aidatainsight.android.feature.setting.data

import com.aidatainsight.android.core.account.runtime.AccountGraph
import com.aidatainsight.android.core.account.runtime.AccountRuntime
import com.aidatainsight.android.core.model.setting.SettingAccountInfo
import com.aidatainsight.android.core.model.setting.SettingCapability
import com.aidatainsight.android.core.model.setting.SettingSnapshot
import com.aidatainsight.android.feature.setting.domain.SettingRepository

class DefaultSettingRepository(
    private val accountGraph: AccountGraph = AccountRuntime.graph,
) : SettingRepository {
    override suspend fun loadSnapshot(): SettingSnapshot {
        val remoteUser = accountGraph.accountRemoteService.getUserInfo().getOrNull()
        val cachedUser = accountGraph.userStore.getUser()
        val user = remoteUser ?: cachedUser
        val session = accountGraph.sessionStore.currentSession()

        return SettingSnapshot(
            accountInfo = SettingAccountInfo(
                nickname = user?.nickname,
                username = user?.username ?: session?.username,
                phone = user?.phone,
            ),
            capability = SettingCapability(
                canUpdatePassword = true,
                canOpenPrivacy = true,
                canLogout = true,
            ),
            appVersion = "0.1.0 (1)",
        )
    }

    override suspend fun logout(): Result<Unit> {
        return accountGraph.authService.logout()
    }
}
