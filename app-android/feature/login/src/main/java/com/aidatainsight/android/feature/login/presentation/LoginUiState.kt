package com.aidatainsight.android.feature.login.presentation

data class LoginUiState(
    val username: String = "demo",
    val password: String = "demo@123",
    val isPrivacyAccepted: Boolean = true,
    val isLoading: Boolean = false,
    val errorMessage: String? = null,
) {
    val canLogin: Boolean
        get() = username.isNotBlank() && password.isNotBlank() && !isLoading
}
