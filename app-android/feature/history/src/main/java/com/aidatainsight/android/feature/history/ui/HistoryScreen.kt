package com.aidatainsight.android.feature.history.ui

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.wrapContentWidth
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Snackbar
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
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
            HistoryTopBar(
                title = uiState.title,
                onOpenSettings = onOpenSettings,
            )

            if (uiState.isLoading && uiState.sections.isEmpty()) {
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
                    contentPadding = PaddingValues(top = 8.dp, bottom = 20.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp),
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
                                modifier = Modifier.padding(top = 12.dp, bottom = 2.dp),
                            )
                        }
                        items(section.items, key = { it.id }) { item ->
                            HistoryRow(
                                item = item,
                                deleteEnabled = !uiState.isDeleting,
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
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(top = 8.dp),
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
private fun HistoryTopBar(
    title: String,
    onOpenSettings: (() -> Unit)?,
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(bottom = 8.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(
            text = title,
            style = MaterialTheme.typography.titleLarge,
            fontWeight = FontWeight.SemiBold,
            color = AIDataInsightThemeTokens.colors.label.primary,
        )
        onOpenSettings?.let {
            TextButton(onClick = it) {
                Text("设置")
            }
        }
    }
}

@OptIn(ExperimentalFoundationApi::class)
@Composable
private fun HistoryRow(
    item: HistoryItemUiModel,
    deleteEnabled: Boolean,
    onOpen: () -> Unit,
    onDelete: () -> Unit,
) {
    val colors = AIDataInsightThemeTokens.colors
    var menuExpanded by remember { mutableStateOf(false) }

    Box(modifier = Modifier.fillMaxWidth()) {
        Surface(
            modifier = Modifier
                .wrapContentWidth(Alignment.Start)
                .clip(RoundedCornerShape(16.dp))
                .combinedClickable(
                    onClick = onOpen,
                    onLongClick = { menuExpanded = true },
                ),
            color = colors.groupedBackground.tertiary,
            shape = RoundedCornerShape(16.dp),
            tonalElevation = 0.dp,
        ) {
            Row(
                modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
                verticalAlignment = Alignment.Bottom,
            ) {
                Text(
                    text = item.title.ifBlank { "未命名会话" },
                    style = MaterialTheme.typography.bodyMedium,
                    color = colors.label.secondary,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis,
                )
                if (item.displayTime.isNotBlank()) {
                    Text(
                        text = " ${item.displayTime}",
                        style = MaterialTheme.typography.labelSmall,
                        color = colors.label.tertiary,
                        maxLines = 1,
                    )
                }
            }
        }

        DropdownMenu(
            expanded = menuExpanded,
            onDismissRequest = { menuExpanded = false },
        ) {
            DropdownMenuItem(
                enabled = deleteEnabled,
                text = { Text("删除") },
                onClick = {
                    menuExpanded = false
                    onDelete()
                },
            )
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
