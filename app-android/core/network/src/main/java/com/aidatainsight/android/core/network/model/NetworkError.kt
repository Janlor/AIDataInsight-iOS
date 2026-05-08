package com.aidatainsight.android.core.network.model

class NetworkException(
    val errorCode: Int? = null,
    override val message: String,
    cause: Throwable? = null,
) : Exception(message, cause)

