package com.aidatainsight.android.feature.aichat.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Snackbar
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.aidatainsight.android.core.ui.theme.AIDataInsightThemeTokens
import com.aidatainsight.android.feature.aichat.presentation.AIChatMessageContentKindUi
import com.aidatainsight.android.feature.aichat.presentation.AIChatMessageRoleUi
import com.aidatainsight.android.feature.aichat.presentation.AIChatMessageUiModel
import com.aidatainsight.android.feature.aichat.presentation.AIChatViewModel

@Composable
fun AIChatScreen(
    modifier: Modifier = Modifier,
    showHeader: Boolean = true,
    drawBackground: Boolean = true,
    viewModel: AIChatViewModel = viewModel(),
) {
    val uiState by viewModel.uiState.collectAsState()
    val lazyListState = rememberLazyListState()

    val content: @Composable () -> Unit = {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 16.dp, vertical = 12.dp),
        ) {
            if (showHeader) {
                AIChatHeader(isLoading = uiState.isLoading)
                Spacer(modifier = Modifier.height(12.dp))
            }

            LazyColumn(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth(),
                state = lazyListState,
                contentPadding = PaddingValues(top = 8.dp, bottom = 12.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                if (uiState.templateQuestions.isNotEmpty()) {
                    item {
                        WelcomeBubble(
                            questions = uiState.templateQuestions,
                            onQuestionClick = viewModel::send,
                        )
                    }
                }

                if (uiState.messages.isEmpty() && uiState.templateQuestions.isEmpty() && uiState.isLoadingTemplate) {
                    item {
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 32.dp),
                            contentAlignment = Alignment.Center,
                        ) {
                            CircularProgressIndicator()
                        }
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

            ChatComposer(
                input = uiState.input,
                canSend = uiState.canSend,
                isLoading = uiState.isLoading,
                onInputChange = viewModel::updateInput,
                onSend = viewModel::sendCurrentMessage,
            )
        }
    }

    if (drawBackground) {
        AIChatBackground(modifier = modifier.fillMaxSize()) {
            content()
        }
    } else {
        Box(modifier = modifier.fillMaxSize()) {
            content()
        }
    }

    LaunchedEffect(uiState.templateQuestions.size, uiState.messages.size) {
        val welcomeCount = if (uiState.templateQuestions.isNotEmpty()) 1 else 0
        val lastIndex = welcomeCount + uiState.messages.size - 1
        if (lastIndex >= 0) {
            lazyListState.animateScrollToItem(lastIndex)
        }
    }
}

@Composable
private fun AIChatHeader(isLoading: Boolean) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(
            text = "AI数据分析助手",
            style = MaterialTheme.typography.titleLarge,
            fontWeight = FontWeight.SemiBold,
            color = AIDataInsightThemeTokens.colors.label.primary,
        )
        if (isLoading) {
            CircularProgressIndicator(modifier = Modifier.padding(4.dp))
        }
    }
}

@Composable
private fun WelcomeBubble(
    questions: List<String>,
    onQuestionClick: (String) -> Unit,
) {
    AssistantBubble {
        Text(
            text = "你好，我是你的AI数据分析助手。我能根据业绩、库存、代采、应收、帐龄等领域的问题生成相应的智能图表。\n你也可以尝试点击以下推荐问题：",
            style = MaterialTheme.typography.bodyMedium,
            color = AIDataInsightThemeTokens.colors.label.primary,
        )

        Column(modifier = Modifier.padding(top = 4.dp)) {
            questions.forEachIndexed { index, question ->
                Text(
                    text = question,
                    modifier = Modifier
                        .fillMaxWidth()
                        .clickable { onQuestionClick(question) }
                        .padding(vertical = 10.dp),
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.primary,
                )
                if (index < questions.lastIndex) {
                    Spacer(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(1.dp)
                            .background(AIDataInsightThemeTokens.colors.separator),
                    )
                }
            }
        }

        Text(
            text = "我能精准识别问题中的指标名称、时间范围、分组维度和过滤条件，例如：",
            modifier = Modifier.padding(top = 12.dp),
            style = MaterialTheme.typography.bodyMedium,
            color = AIDataInsightThemeTokens.colors.label.primary,
        )

        QueryExampleRow(modifier = Modifier.padding(top = 10.dp))
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun QueryExampleRow(modifier: Modifier = Modifier) {
    val examples = listOf(
        "今年第一季度" to "时间范围",
        "销售额" to "指标名称",
        "大于5000万" to "过滤条件",
        "的" to "",
        "公司。" to "分组维度",
    )
    FlowRow(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        examples.forEach { (top, bottom) ->
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text(
                    text = top,
                    style = MaterialTheme.typography.labelMedium,
                    fontWeight = FontWeight.SemiBold,
                    color = AIDataInsightThemeTokens.colors.label.primary,
                )
                Text(
                    text = bottom,
                    style = MaterialTheme.typography.labelSmall,
                    color = AIDataInsightThemeTokens.colors.label.tertiary,
                )
            }
        }
    }
}

@Composable
private fun MessageBubble(message: AIChatMessageUiModel) {
    val isUser = message.role == AIChatMessageRoleUi.User
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = if (isUser) Arrangement.End else Arrangement.Start,
    ) {
        if (isUser) {
            UserBubble(text = message.text)
        } else {
            AssistantBubble {
                if (message.contentKind == AIChatMessageContentKindUi.Chart) {
                    Text(
                        text = "根据您的查询，以下是分析结果:",
                        style = MaterialTheme.typography.labelMedium,
                        color = AIDataInsightThemeTokens.colors.label.secondary,
                    )
                }
                Text(
                    text = message.text,
                    style = MaterialTheme.typography.bodyMedium,
                    color = AIDataInsightThemeTokens.colors.label.primary,
                )
            }
        }
    }
}

@Composable
private fun AssistantBubble(content: @Composable ColumnScope.() -> Unit) {
    val colors = AIDataInsightThemeTokens.colors
    Column(
        modifier = Modifier
            .widthIn(max = 560.dp)
            .clip(RoundedCornerShape(topStart = 21.dp, topEnd = 21.dp, bottomStart = 4.dp, bottomEnd = 21.dp))
            .background(colors.groupedBackground.secondary)
            .border(
                width = 0.5.dp,
                color = colors.separator,
                shape = RoundedCornerShape(topStart = 21.dp, topEnd = 21.dp, bottomStart = 4.dp, bottomEnd = 21.dp),
            )
            .padding(horizontal = 16.dp, vertical = 12.dp),
        verticalArrangement = Arrangement.spacedBy(6.dp),
        content = content,
    )
}

@Composable
private fun UserBubble(text: String) {
    val shape = RoundedCornerShape(topStart = 21.dp, topEnd = 21.dp, bottomStart = 21.dp, bottomEnd = 4.dp)
    Box(
        modifier = Modifier
            .widthIn(max = 420.dp)
            .clip(shape)
            .background(
                Brush.linearGradient(
                    colors = listOf(
                        Color(0xFFF5FAFF),
                        Color(0xFFEAF5FF),
                        Color(0xFFD1E8FF),
                    ),
                ),
            )
            .padding(horizontal = 16.dp, vertical = 12.dp),
    ) {
        Text(
            text = text,
            style = MaterialTheme.typography.bodyMedium,
            fontWeight = FontWeight.SemiBold,
            color = AIDataInsightThemeTokens.colors.label.primary,
            maxLines = 12,
            overflow = TextOverflow.Ellipsis,
        )
    }
}

@Composable
private fun ChatComposer(
    input: String,
    canSend: Boolean,
    isLoading: Boolean,
    onInputChange: (String) -> Unit,
    onSend: () -> Unit,
) {
    val colors = AIDataInsightThemeTokens.colors
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(21.dp))
            .background(colors.groupedBackground.secondary)
            .border(1.dp, colors.separator, RoundedCornerShape(21.dp))
            .padding(start = 16.dp, top = 4.dp, end = 4.dp, bottom = 4.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Box(
            modifier = Modifier
                .weight(1f)
                .heightIn(min = 34.dp),
            contentAlignment = Alignment.CenterStart,
        ) {
            if (input.isBlank()) {
                Text(
                    text = "请输入您的数据分析查询。",
                    style = MaterialTheme.typography.bodyMedium,
                    fontWeight = FontWeight.SemiBold,
                    color = colors.label.quaternary,
                )
            }
            BasicTextField(
                value = input,
                onValueChange = onInputChange,
                enabled = !isLoading,
                textStyle = MaterialTheme.typography.bodyMedium.copy(
                    color = colors.label.primary,
                    fontWeight = FontWeight.SemiBold,
                ),
                minLines = 1,
                maxLines = 5,
                modifier = Modifier.fillMaxWidth(),
            )
        }
        TextButton(
            onClick = onSend,
            enabled = canSend,
        ) {
            Text("发送")
        }
    }
}
