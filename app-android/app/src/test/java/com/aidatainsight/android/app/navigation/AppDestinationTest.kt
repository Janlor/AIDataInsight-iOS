package com.aidatainsight.android.app.navigation

import kotlin.test.Test
import kotlin.test.assertEquals

class AppDestinationTest {
    @Test
    fun routes_areStableForAppNavigation() {
        assertEquals("login", AppDestination.Login.route)
        assertEquals("ai_home", AppDestination.AIHome.route)
        assertEquals("setting", AppDestination.Setting.route)
        assertEquals("privacy", AppDestination.Privacy.route)
        assertEquals("history", AppDestination.History.route)
        assertEquals("ai_chat", AppDestination.AIChat.route)
    }
}
