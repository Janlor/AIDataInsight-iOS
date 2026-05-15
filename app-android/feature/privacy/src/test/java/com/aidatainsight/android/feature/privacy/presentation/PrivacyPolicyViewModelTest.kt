package com.aidatainsight.android.feature.privacy.presentation

import com.aidatainsight.android.feature.privacy.domain.PrivacyRepository
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

class PrivacyPolicyViewModelTest {
    @Test
    fun evaluate_showsPolicyOnceWhenNotAgreed() {
        val viewModel = PrivacyPolicyViewModel(FakePrivacyRepository(isAgreed = false))

        viewModel.evaluate()
        assertTrue(viewModel.uiState.value.shouldShow)
        assertEquals("file:///android_asset/privacy_policy.html", viewModel.uiState.value.privacyPolicyUrl)

        viewModel.evaluate()
        assertTrue(viewModel.uiState.value.shouldShow)
    }

    @Test
    fun evaluate_doesNotShowWhenAlreadyAgreed() {
        val viewModel = PrivacyPolicyViewModel(FakePrivacyRepository(isAgreed = true))

        viewModel.evaluate()

        assertFalse(viewModel.uiState.value.shouldShow)
    }

    @Test
    fun privacyPolicyUrl_usesRepositoryUrl() {
        val viewModel = PrivacyPolicyViewModel(FakePrivacyRepository(isAgreed = true))

        assertEquals("file:///android_asset/privacy_policy.html", viewModel.privacyPolicyUrl())
    }
}

private class FakePrivacyRepository(
    private val isAgreed: Boolean,
) : PrivacyRepository {
    override fun isAgreedAllPolicyAgreement(): Boolean = isAgreed

    override fun saveLatestAgreement() = Unit

    override fun privacyPolicyUrl(): String = "file:///android_asset/privacy_policy.html"
}
