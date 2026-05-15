package com.aidatainsight.android.core.network.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.json.JsonNames

@Serializable
data class LoginRequest(
    val name: String,
    val pwd: String,
)

@Serializable
@OptIn(ExperimentalSerializationApi::class)
data class OAuthModel(
    @JsonNames("access_token")
    val accessToken: String? = null,
    @JsonNames("refresh_token")
    val refreshToken: String? = null,
    @JsonNames("org_id")
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
