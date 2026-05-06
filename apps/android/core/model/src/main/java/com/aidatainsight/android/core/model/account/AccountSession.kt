package com.aidatainsight.android.core.model.account

import kotlinx.serialization.Serializable

@Serializable
data class AccountSession(
    val accessToken: String? = null,
    val refreshToken: String? = null,
    val orgId: Int? = null,
    val username: String? = null,
)
