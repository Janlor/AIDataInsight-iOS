package com.aidatainsight.android.feature.aichat.application

import com.aidatainsight.android.core.model.contract.AIChatIntentType
import com.aidatainsight.android.core.model.contract.FunctionArguments

object AIChatIntentResolver {
    fun resolve(arguments: FunctionArguments): AIChatIntentType? {
        return when (arguments) {
            is FunctionArguments.TimeRange -> {
                if (arguments.value.startDate.isNullOrBlank()) AIChatIntentType.Time else null
            }
            is FunctionArguments.PerformanceType -> AIChatIntentType.Index
            else -> null
        }
    }
}

