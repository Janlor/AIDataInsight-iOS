package com.aidatainsight.android.core.model.aichat

data class AIChatMessage(
    val id: String,
    val role: AIChatRole,
    val content: String,
)

enum class AIChatRole {
    Assistant,
    User,
    System,
}
