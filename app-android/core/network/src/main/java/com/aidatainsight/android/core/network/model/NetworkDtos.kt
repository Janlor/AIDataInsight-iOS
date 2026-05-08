package com.aidatainsight.android.core.network.model

import kotlinx.serialization.Serializable

@Serializable
data class LoginRequest(
    val name: String,
    val pwd: String,
)

@Serializable
data class OAuthModel(
    val accessToken: String? = null,
    val refreshToken: String? = null,
    val orgId: Int? = null,
    val username: String? = null,
)

@Serializable
data class UpdatePasswordRequest(
    val oldPwd: String,
    val newPwd: String,
)

@Serializable
data class LikeHistoryDetailRequest(
    val historyDetailId: Int,
    val like: String,
)

@Serializable
data class MenuItem(
    val id: Int? = null,
    val name: String? = null,
    val path: String? = null,
    val children: List<MenuItem>? = null,
)

