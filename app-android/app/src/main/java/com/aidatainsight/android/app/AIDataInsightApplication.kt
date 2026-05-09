package com.aidatainsight.android.app

import android.app.Application
import com.aidatainsight.android.core.account.runtime.AccountRuntime

class AIDataInsightApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        AccountRuntime.install(this)
    }
}
