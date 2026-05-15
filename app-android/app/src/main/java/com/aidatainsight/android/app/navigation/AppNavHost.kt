package com.aidatainsight.android.app.navigation

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.aidatainsight.android.app.ui.AIHomeScreen
import com.aidatainsight.android.core.account.runtime.AccountRuntime
import com.aidatainsight.android.feature.aichat.ui.AIChatScreen
import com.aidatainsight.android.feature.history.ui.HistoryScreen
import com.aidatainsight.android.feature.login.ui.LoginScreen
import com.aidatainsight.android.feature.privacy.ui.PrivacyScreen
import com.aidatainsight.android.feature.setting.ui.SettingScreen

@Composable
fun AppNavHost() {
    val navController = rememberNavController()
    val startDestination = remember {
        if (AccountRuntime.graph.sessionStore.isLogin) {
            AppDestination.AIHome.route
        } else {
            AppDestination.Login.route
        }
    }

    NavHost(
        navController = navController,
        startDestination = startDestination,
    ) {
        composable(AppDestination.Login.route) {
            LoginScreen(
                onLoginSuccess = {
                    navController.navigateToAIHomeAndClearBackStack()
                },
                onOpenPrivacy = {
                    navController.navigate(AppDestination.Privacy.route)
                },
            )
        }
        composable(AppDestination.AIHome.route) {
            AIHomeScreen(
                onOpenSettings = { navController.navigate(AppDestination.Setting.route) },
            )
        }
        composable(AppDestination.Setting.route) {
            SettingScreen(
                onOpenPrivacy = { navController.navigate(AppDestination.Privacy.route) },
                onOpenHistory = { navController.navigate(AppDestination.History.route) },
                onOpenAIChat = { navController.navigate(AppDestination.AIHome.route) },
                onLogout = {
                    navController.navigateToLoginAndClearBackStack()
                },
            )
        }
        composable(AppDestination.Privacy.route) {
            PrivacyScreen()
        }
        composable(AppDestination.History.route) {
            HistoryScreen(respectSafeDrawingArea = true)
        }
        composable(AppDestination.AIChat.route) {
            AIChatScreen()
        }
    }
}

private fun NavHostController.navigateToAIHomeAndClearBackStack() {
    navigate(AppDestination.AIHome.route) {
        popUpTo(graph.findStartDestination().id) { inclusive = true }
        launchSingleTop = true
    }
}

private fun NavHostController.navigateToLoginAndClearBackStack() {
    navigate(AppDestination.Login.route) {
        popUpTo(graph.findStartDestination().id) { inclusive = true }
        launchSingleTop = true
    }
}
