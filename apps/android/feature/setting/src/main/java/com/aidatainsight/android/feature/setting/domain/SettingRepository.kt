package com.aidatainsight.android.feature.setting.domain

import com.aidatainsight.android.core.model.setting.SettingSnapshot

interface SettingRepository {
    suspend fun loadSnapshot(): SettingSnapshot
    suspend fun logout(): Result<Unit>
}
