package com.aidatainsight.android.core.model.setting

data class SettingAccountInfo(
    val nickname: String?,
    val username: String?,
    val phone: String?,
)

data class SettingCapability(
    val canUpdatePassword: Boolean,
    val canOpenPrivacy: Boolean,
    val canLogout: Boolean,
)

data class SettingSnapshot(
    val accountInfo: SettingAccountInfo,
    val capability: SettingCapability,
    val appVersion: String,
)
