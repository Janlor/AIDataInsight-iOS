package com.aidatainsight.android.core.network.auth

import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock

class TokenRefreshCoordinator(
    private val tokenRefreshService: TokenRefreshService,
) {
    private val refreshMutex = Mutex()

    suspend fun refreshIfNeeded(token: String?): Boolean {
        val refreshToken = token ?: return false
        return refreshMutex.withLock {
            tokenRefreshService.refreshToken(refreshToken)
        }
    }
}
