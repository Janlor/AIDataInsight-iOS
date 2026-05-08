package com.aidatainsight.android.core.network.service

import com.aidatainsight.android.core.model.contract.AccountUser
import com.aidatainsight.android.core.network.client.AIDataInsightApiClient
import com.aidatainsight.android.core.network.model.MenuItem
import com.aidatainsight.android.core.network.model.UpdatePasswordRequest

interface AccountRemoteService {
    suspend fun getUserInfo(): AccountUser?
    suspend fun updatePassword(oldPassword: String, newPassword: String)
    suspend fun getMenuTree(): List<MenuItem>
}

class KtorAccountRemoteService(
    private val apiClient: AIDataInsightApiClient,
) : AccountRemoteService {
    override suspend fun getUserInfo(): AccountUser? {
        return apiClient.get(path = "/oauth2/getUserInfo")
    }

    override suspend fun updatePassword(oldPassword: String, newPassword: String) {
        apiClient.postEmpty(
            path = "/oauth2/updatePwd",
            body = UpdatePasswordRequest(oldPwd = oldPassword, newPwd = newPassword),
        )
    }

    override suspend fun getMenuTree(): List<MenuItem> {
        return apiClient.get<List<MenuItem>>(path = "/oauth2/menuTree").orEmpty()
    }
}

