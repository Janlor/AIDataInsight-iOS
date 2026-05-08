package com.aidatainsight.android.feature.aichat.application.usecase

class LoadChartDataUseCase {
    operator fun invoke(messages: List<String>): List<String> = messages.mapIndexed { index, message ->
        "Chart $index: $message"
    }
}
