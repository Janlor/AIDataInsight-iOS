package com.aidatainsight.android.core.network.service

import com.aidatainsight.android.core.network.client.AIDataInsightApiClient
import com.aidatainsight.android.core.network.model.LoginRequest
import com.aidatainsight.android.core.network.model.OAuthModel

interface AuthRemoteService {
    suspend fun login(username: String, password: String): OAuthModel?
    suspend fun refreshToken(refreshToken: String): OAuthModel?
    suspend fun logout()
}

class KtorAuthRemoteService(
    private val apiClient: AIDataInsightApiClient,
) : AuthRemoteService {
    override suspend fun login(username: String, password: String): OAuthModel? {
        return apiClient.post(
            path = "/oauth2/login",
            body = LoginRequest(name = username, pwd = password),
        )
    }

    override suspend fun refreshToken(refreshToken: String): OAuthModel? {
        return apiClient.get(
            path = "/oauth2/refresh",
            query = mapOf("refreshToken" to refreshToken),
        )
    }

    override suspend fun logout() {
        apiClient.getEmpty(path = "/oauth2/logout")
    }
}

