package com.aidatainsight.android.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import com.aidatainsight.android.app.navigation.AppNavHost
import com.aidatainsight.android.core.ui.theme.AIDataInsightTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
        setContent {
            AIDataInsightTheme {
                AppNavHost()
            }
        }
    }
}
