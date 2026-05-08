package com.aidatainsight.android.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import com.aidatainsight.android.app.navigation.AppNavHost
import com.aidatainsight.android.core.ui.theme.AIDataInsightTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            AIDataInsightTheme {
                AppNavHost()
            }
        }
    }
}
