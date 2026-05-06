package com.aidatainsight.android.core.network.model

import kotlinx.serialization.Serializable

@Serializable
data class ApiResponse<T>(
    val code: Int? = null,
    val msg: String? = null,
    val data: T? = null,
    val trace: String? = null,
    val tid: String? = null,
)
