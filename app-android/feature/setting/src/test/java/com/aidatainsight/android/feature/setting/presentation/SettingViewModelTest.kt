package com.aidatainsight.android.feature.setting.presentation

import com.aidatainsight.android.core.model.setting.SettingAccountInfo
import com.aidatainsight.android.core.model.setting.SettingCapability
import com.aidatainsight.android.core.model.setting.SettingSnapshot
import com.aidatainsight.android.feature.setting.domain.SettingRepository
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.delay
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runCurrent
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

@OptIn(ExperimentalCoroutinesApi::class)
class SettingViewModelTest {
    private val dispatcher = StandardTestDispatcher()

    @BeforeTest
    fun setUp() {
        Dispatchers.setMain(dispatcher)
    }

    @AfterTest
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun refresh_loadsSnapshot() = runTest(dispatcher) {
        val snapshot = settingSnapshot()
        val viewModel = SettingViewModel(FakeSettingRepository(cachedSnapshot = snapshot))

        advanceUntilIdle()

        assertEquals(snapshot, viewModel.uiState.value.snapshot)
        assertFalse(viewModel.uiState.value.isLoading)
    }

    @Test
    fun refresh_showsCachedSnapshotBeforeRemoteRefresh() = runTest(dispatcher) {
        val cached = settingSnapshot(nickname = "Cached Janlor")
        val remote = settingSnapshot(nickname = "Remote Janlor")
        val repository = FakeSettingRepository(
            cachedSnapshot = cached,
            remoteSnapshot = Result.success(remote),
            remoteDelayMillis = 1_000,
        )
        val viewModel = SettingViewModel(repository)

        runCurrent()

        assertEquals(cached, viewModel.uiState.value.snapshot)
        assertFalse(viewModel.uiState.value.isLoading)

        advanceUntilIdle()

        assertEquals(remote, viewModel.uiState.value.snapshot)
        assertTrue(repository.didRefreshRemote)
    }

    @Test
    fun logout_successCallsCallback() = runTest(dispatcher) {
        val repository = FakeSettingRepository(cachedSnapshot = settingSnapshot())
        val viewModel = SettingViewModel(repository)
        advanceUntilIdle()
        var didLogout = false

        viewModel.logout { didLogout = true }
        advanceUntilIdle()

        assertTrue(didLogout)
        assertTrue(repository.didLogout)
        assertFalse(viewModel.uiState.value.isLoggingOut)
    }
}

private class FakeSettingRepository(
    private val cachedSnapshot: SettingSnapshot,
    private val remoteSnapshot: Result<SettingSnapshot> = Result.failure(IllegalStateException("remote unavailable")),
    private val remoteDelayMillis: Long = 0,
    private val logoutResult: Result<Unit> = Result.success(Unit),
) : SettingRepository {
    var didLogout = false
        private set
    var didRefreshRemote = false
        private set

    override suspend fun loadCachedSnapshot(): SettingSnapshot = cachedSnapshot

    override suspend fun refreshRemoteSnapshot(): Result<SettingSnapshot> {
        didRefreshRemote = true
        if (remoteDelayMillis > 0) delay(remoteDelayMillis)
        return remoteSnapshot
    }

    override suspend fun logout(): Result<Unit> {
        didLogout = true
        return logoutResult
    }
}

private fun settingSnapshot(
    nickname: String = "Janlor",
) = SettingSnapshot(
    accountInfo = SettingAccountInfo(
        nickname = nickname,
        username = "janlor",
        phone = "13800000000",
    ),
    capability = SettingCapability(
        canUpdatePassword = true,
        canOpenPrivacy = true,
        canLogout = true,
    ),
    appVersion = "0.1.0",
)
