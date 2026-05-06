package com.aidatainsight.android.core.model.account

import kotlinx.serialization.Serializable

@Serializable
data class AccountUser(
    val id: Int? = null,
    val phone: String? = null,
    val username: String? = null,
    val nickname: String? = null,
)
