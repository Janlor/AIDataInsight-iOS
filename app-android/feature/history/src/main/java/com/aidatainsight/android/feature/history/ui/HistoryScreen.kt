package com.aidatainsight.android.feature.history.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Snackbar
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.aidatainsight.android.core.ui.layout.AIDataInsightGradientBackground
import com.aidatainsight.android.core.ui.theme.AIDataInsightThemeTokens
import com.aidatainsight.android.feature.history.presentation.HistoryItemUiModel
import com.aidatainsight.android.feature.history.presentation.HistoryViewModel

@Composable
fun HistoryScreen(
    modifier: Modifier = Modifier,
    drawBackground: Boolean = true,
    respectSafeDrawingArea: Boolean = true,
    onOpenHistory: (String) -> Unit = {},
    onOpenSettings: (() -> Unit)? = null,
    viewModel: HistoryViewModel = viewModel(),
) {
    val uiState by viewModel.uiState.collectAsState()
    val colors = AIDataInsightThemeTokens.colors

    val content: @Composable () -> Unit = {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .then(if (drawBackground) Modifier else Modifier.background(colors.groupedBackground.primary))
            .padding(horizontal = 16.dp, vertical = 12.dp),
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Column {
                Text(
                    text = "历史记录",
                    style = MaterialTheme.typography.headlineSmall,
                    fontWeight = FontWeight.SemiBold,
                )
                Text(
                    text = "${uiState.sections.sumOf { it.items.size }} 条会话",
                    style = MaterialTheme.typography.bodyMedium,
                    color = colors.label.secondary,
                )
            }
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                onOpenSettings?.let {
                    OutlinedButton(onClick = it) {
                        Text("设置")
                    }
                }
                OutlinedButton(
                    onClick = { viewModel.refresh(silent = false) },
                    enabled = !uiState.isLoading,
                ) {
                    Text("刷新")
                }
                Button(
                    onClick = viewModel::deleteAll,
                    enabled = uiState.sections.isNotEmpty() && !uiState.isLoading,
                ) {
                    Text("清空")
                }
            }
        }

        if (uiState.isLoading) {
            Box(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth(),
                contentAlignment = Alignment.Center,
            ) {
                CircularProgressIndicator()
            }
        } else {
            LazyColumn(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth(),
                contentPadding = PaddingValues(vertical = 12.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                if (uiState.sections.isEmpty()) {
                    item {
                        EmptyHistory()
                    }
                }

                uiState.sections.forEach { section ->
                    item(key = "section-${section.title}") {
                        Text(
                            text = section.title,
                            style = MaterialTheme.typography.titleSmall,
                            color = colors.label.secondary,
                            modifier = Modifier.padding(top = 4.dp),
                        )
                    }
                    items(section.items, key = { it.id }) { item ->
                        HistoryRow(
                            item = item,
                            onOpen = { onOpenHistory(item.id) },
                            onDelete = { viewModel.delete(item.id) },
                        )
                    }
                }

                if (uiState.hasMore) {
                    item {
                        OutlinedButton(
                            onClick = viewModel::loadMore,
                            enabled = !uiState.isLoadingMore,
                            modifier = Modifier.fillMaxWidth(),
                        ) {
                            Text(if (uiState.isLoadingMore) "加载中" else "加载更多")
                        }
                    }
                }
            }
        }

        uiState.errorMessage?.let { message ->
            Snackbar(
                action = {
                    TextButton(onClick = viewModel::dismissError) { Text("关闭") }
                },
            ) {
                Text(message)
            }
        }
    }
    }

    if (drawBackground) {
        AIDataInsightGradientBackground(
            modifier = modifier.fillMaxSize(),
            respectSafeDrawingArea = respectSafeDrawingArea,
        ) {
            content()
        }
    } else {
        Box(modifier = modifier.fillMaxSize()) {
            content()
        }
    }
}

@Composable
private fun HistoryRow(
    item: HistoryItemUiModel,
    onOpen: () -> Unit,
    onDelete: () -> Unit,
) {
    val colors = AIDataInsightThemeTokens.colors
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(colors.groupedBackground.secondary, RoundedCornerShape(8.dp))
            .clickable(onClick = onOpen)
            .padding(12.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = item.title.ifBlank { "未命名会话" },
                style = MaterialTheme.typography.bodyLarge,
                color = colors.label.primary,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
            Text(
                text = "ID ${item.id}",
                style = MaterialTheme.typography.bodySmall,
                color = colors.label.tertiary,
            )
        }
        TextButton(onClick = onDelete) {
            Text("删除")
        }
    }
}

@Composable
private fun EmptyHistory() {
    val colors = AIDataInsightThemeTokens.colors
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 40.dp),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            text = "暂无历史记录",
            style = MaterialTheme.typography.bodyMedium,
            color = colors.label.secondary,
        )
    }
}
