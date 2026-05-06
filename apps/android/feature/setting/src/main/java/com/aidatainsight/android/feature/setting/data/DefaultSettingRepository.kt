package com.aidatainsight.android.feature.setting.data

import com.aidatainsight.android.core.model.setting.SettingAccountInfo
import com.aidatainsight.android.core.model.setting.SettingCapability
import com.aidatainsight.android.core.model.setting.SettingSnapshot
import com.aidatainsight.android.feature.setting.domain.SettingRepository

class DefaultSettingRepository : SettingRepository {
    override suspend fun loadSnapshot(): SettingSnapshot {
        return SettingSnapshot(
            accountInfo = SettingAccountInfo(
                nickname = "Demo User",
                username = "demo",
                phone = "13800138000",
            ),
            capability = SettingCapability(
                canUpdatePassword = true,
                canOpenPrivacy = true,
                canLogout = true,
            ),
            appVersion = "0.1.0 (1)",
        )
    }

    override suspend fun logout(): Result<Unit> = Result.success(Unit)
}
