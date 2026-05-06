package com.aidatainsight.android.app.navigation

sealed class AppDestination(val route: String) {
    data object Login : AppDestination("login")
    data object Setting : AppDestination("setting")
    data object Privacy : AppDestination("privacy")
    data object History : AppDestination("history")
    data object AIChat : AppDestination("ai_chat")
}
