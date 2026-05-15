package com.aidatainsight.android.feature.login.presentation

import com.aidatainsight.android.core.model.account.AccountSession
import com.aidatainsight.android.feature.login.domain.LoginRepository
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
class LoginViewModelTest {
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
    fun input_isTrimmedToContractLength() {
        val viewModel = LoginViewModel(FakeLoginRepository())

        viewModel.updateUsername("u".repeat(40))
        viewModel.updatePassword("p".repeat(40))

        assertEquals(LoginViewModel.MAX_USERNAME_LENGTH, viewModel.uiState.value.username.length)
        assertEquals(LoginViewModel.MAX_PASSWORD_LENGTH, viewModel.uiState.value.password.length)
    }

    @Test
    fun login_requiresPrivacyAgreement() {
        val viewModel = LoginViewModel(FakeLoginRepository())
        viewModel.updateUsername("janlor")
        viewModel.updatePassword("123456")
        viewModel.togglePrivacyAccepted()

        viewModel.login {}

        assertEquals("请先阅读并同意《隐私政策》", viewModel.uiState.value.errorMessage)
    }

    @Test
    fun login_successCallsCallbackAndClearsLoading() = runTest(dispatcher) {
        val repository = FakeLoginRepository()
        val viewModel = LoginViewModel(repository)
        var didLogin = false

        viewModel.updateUsername("janlor")
        viewModel.updatePassword("123456")
        viewModel.login { didLogin = true }
        advanceUntilIdle()

        assertTrue(didLogin)
        assertFalse(viewModel.uiState.value.isLoading)
        assertEquals("janlor", repository.username)
        assertEquals("123456", repository.password)
    }
}

private class FakeLoginRepository(
    private val result: Result<AccountSession> = Result.success(AccountSession(accessToken = "token")),
) : LoginRepository {
    var username: String? = null
        private set
    var password: String? = null
        private set

    override suspend fun login(username: String, password: String): Result<AccountSession> {
        this.username = username
        this.password = password
        return result
    }
}
