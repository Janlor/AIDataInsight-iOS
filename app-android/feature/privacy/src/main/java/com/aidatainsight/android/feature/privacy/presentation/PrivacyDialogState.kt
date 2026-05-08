package com.aidatainsight.android.feature.privacy.presentation

data class PrivacyDialogState(
    val shouldShow: Boolean = false,
    val privacyPolicyUrl: String = "",
)
