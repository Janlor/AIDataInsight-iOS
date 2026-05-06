package com.aidatainsight.android.app.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.aidatainsight.android.feature.aichat.ui.AIChatScreen
import com.aidatainsight.android.feature.history.ui.HistoryScreen
import com.aidatainsight.android.feature.login.ui.LoginScreen
import com.aidatainsight.android.feature.privacy.ui.PrivacyScreen
import com.aidatainsight.android.feature.setting.ui.SettingScreen

@Composable
fun AppNavHost() {
    val navController = rememberNavController()

    NavHost(
        navController = navController,
        startDestination = AppDestination.Login.route,
    ) {
        composable(AppDestination.Login.route) {
            LoginScreen(onLoginSuccess = {
                navController.navigate(AppDestination.Setting.route)
            })
        }
        composable(AppDestination.Setting.route) {
            SettingScreen(
                onOpenPrivacy = { navController.navigate(AppDestination.Privacy.route) },
                onOpenHistory = { navController.navigate(AppDestination.History.route) },
                onOpenAIChat = { navController.navigate(AppDestination.AIChat.route) },
            )
        }
        composable(AppDestination.Privacy.route) {
            PrivacyScreen()
        }
        composable(AppDestination.History.route) {
            HistoryScreen()
        }
        composable(AppDestination.AIChat.route) {
            AIChatScreen()
        }
    }
}
