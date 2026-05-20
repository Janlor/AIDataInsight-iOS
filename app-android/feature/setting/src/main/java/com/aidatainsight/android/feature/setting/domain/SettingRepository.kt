package com.aidatainsight.android.feature.setting.domain

import com.aidatainsight.android.core.model.setting.SettingSnapshot

interface SettingRepository {
    suspend fun loadCachedSnapshot(): SettingSnapshot
    suspend fun refreshRemoteSnapshot(): Result<SettingSnapshot>
    suspend fun logout(): Result<Unit>
}
