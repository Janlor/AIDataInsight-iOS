package com.aidatainsight.android.feature.aichat.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.AssistChip
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Snackbar
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.aidatainsight.android.core.ui.theme.AIDataInsightThemeTokens
import com.aidatainsight.android.feature.aichat.presentation.AIChatMessageRoleUi
import com.aidatainsight.android.feature.aichat.presentation.AIChatMessageUiModel
import com.aidatainsight.android.feature.aichat.presentation.AIChatViewModel

@Composable
fun AIChatScreen(viewModel: AIChatViewModel = viewModel()) {
    val uiState by viewModel.uiState.collectAsState()
    val colors = AIDataInsightThemeTokens.colors

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(colors.groupedBackground.primary)
            .padding(horizontal = 16.dp, vertical = 12.dp),
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Column {
                Text(
                    text = "AI Chat",
                    style = MaterialTheme.typography.headlineSmall,
                    fontWeight = FontWeight.SemiBold,
                )
                Text(
                    text = "经营数据分析",
                    style = MaterialTheme.typography.bodyMedium,
                    color = colors.label.secondary,
                )
            }
            if (uiState.isLoading) {
                CircularProgressIndicator(modifier = Modifier.padding(4.dp))
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        LazyColumn(
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth(),
            contentPadding = PaddingValues(vertical = 8.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            if (uiState.templateQuestions.isNotEmpty()) {
                item {
                    TemplateQuestionPanel(
                        questions = uiState.templateQuestions,
                        onQuestionClick = viewModel::useTemplate,
                    )
                }
            }

            if (uiState.messages.isEmpty() && uiState.templateQuestions.isEmpty() && !uiState.isLoading) {
                item {
                    EmptyConversation()
                }
            }

            items(uiState.messages, key = { it.id }) { message ->
                MessageBubble(message)
            }
        }

        uiState.errorMessage?.let { message ->
            Snackbar(
                modifier = Modifier.padding(bottom = 8.dp),
                action = {
                    TextButton(onClick = viewModel::dismissError) { Text("关闭") }
                },
            ) {
                Text(message)
            }
        }

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(10.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            OutlinedTextField(
                value = uiState.input,
                onValueChange = viewModel::updateInput,
                modifier = Modifier.weight(1f),
                label = { Text("输入问题") },
                minLines = 1,
                maxLines = 4,
            )
            Button(
                onClick = viewModel::sendCurrentMessage,
                enabled = uiState.canSend,
            ) {
                Text("发送")
            }
        }
    }
}

@Composable
@OptIn(ExperimentalLayoutApi::class)
private fun TemplateQuestionPanel(
    questions: List<String>,
    onQuestionClick: (String) -> Unit,
) {
    val colors = AIDataInsightThemeTokens.colors
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(colors.groupedBackground.secondary, RoundedCornerShape(8.dp))
            .padding(12.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        Text(
            text = "常用问题",
            style = MaterialTheme.typography.titleSmall,
            color = colors.label.secondary,
        )
        FlowRow(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            questions.forEach { question ->
                AssistChip(
                    onClick = { onQuestionClick(question) },
                    label = { Text(question) },
                )
            }
        }
    }
}

@Composable
private fun MessageBubble(message: AIChatMessageUiModel) {
    val colors = AIDataInsightThemeTokens.colors
    val isUser = message.role == AIChatMessageRoleUi.User
    val bubbleColor = when {
        isUser -> MaterialTheme.colorScheme.primary
        message.isChart -> colors.groupedBackground.tertiary
        else -> colors.groupedBackground.secondary
    }
    val textColor = if (isUser) Color.White else colors.label.primary

    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = if (isUser) Arrangement.End else Arrangement.Start,
    ) {
        Column(
            modifier = Modifier
                .widthIn(max = 320.dp)
                .background(bubbleColor, RoundedCornerShape(8.dp))
                .padding(horizontal = 12.dp, vertical = 10.dp),
            verticalArrangement = Arrangement.spacedBy(6.dp),
        ) {
            if (message.isChart) {
                Text(
                    text = "分析结果",
                    style = MaterialTheme.typography.labelMedium,
                    color = colors.label.secondary,
                )
            }
            Text(
                text = message.text,
                style = MaterialTheme.typography.bodyMedium,
                color = textColor,
            )
        }
    }
}

@Composable
private fun EmptyConversation() {
    val colors = AIDataInsightThemeTokens.colors
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 32.dp),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            text = "暂无会话",
            color = colors.label.secondary,
            style = MaterialTheme.typography.bodyMedium,
        )
    }
}
