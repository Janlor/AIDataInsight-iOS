package com.aidatainsight.android.feature.setting.presentation

import com.aidatainsight.android.core.model.setting.SettingAccountInfo
import com.aidatainsight.android.core.model.setting.SettingCapability
import com.aidatainsight.android.core.model.setting.SettingSnapshot
import com.aidatainsight.android.feature.setting.domain.SettingRepository
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.resetMain
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
        val viewModel = SettingViewModel(FakeSettingRepository(snapshot))

        advanceUntilIdle()

        assertEquals(snapshot, viewModel.uiState.value.snapshot)
        assertFalse(viewModel.uiState.value.isLoading)
    }

    @Test
    fun logout_successCallsCallback() = runTest(dispatcher) {
        val repository = FakeSettingRepository(settingSnapshot())
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
    private val snapshot: SettingSnapshot,
    private val logoutResult: Result<Unit> = Result.success(Unit),
) : SettingRepository {
    var didLogout = false
        private set

    override suspend fun loadSnapshot(): SettingSnapshot = snapshot

    override suspend fun logout(): Result<Unit> {
        didLogout = true
        return logoutResult
    }
}

private fun settingSnapshot() = SettingSnapshot(
    accountInfo = SettingAccountInfo(
        nickname = "Janlor",
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
