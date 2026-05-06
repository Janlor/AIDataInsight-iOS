package com.aidatainsight.android.core.network.auth

interface NetworkCredentialProvider {
    val accessToken: String?
    val refreshToken: String?
    val orgId: Int?
}

interface TokenRefreshService {
    suspend fun refreshToken(token: String): Boolean
}

interface SessionInvalidationHandler {
    fun invalidateSession(message: String?)
}

object NetworkDependencies {
    lateinit var credentialProvider: NetworkCredentialProvider
    lateinit var tokenRefreshService: TokenRefreshService
    lateinit var sessionInvalidationHandler: SessionInvalidationHandler
}
