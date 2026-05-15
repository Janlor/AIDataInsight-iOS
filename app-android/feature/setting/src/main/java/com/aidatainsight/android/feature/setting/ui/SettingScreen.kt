package com.aidatainsight.android.feature.setting.ui

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.aidatainsight.android.core.model.setting.SettingAccountInfo
import com.aidatainsight.android.core.model.setting.SettingSnapshot
import com.aidatainsight.android.core.ui.layout.AIDataInsightGradientBackground
import com.aidatainsight.android.core.ui.theme.AIDataInsightThemeTokens
import com.aidatainsight.android.feature.setting.presentation.SettingViewModel

@Composable
fun SettingScreen(
    onClose: () -> Unit,
    onOpenPrivacy: () -> Unit,
    onLogout: () -> Unit = {},
    viewModel: SettingViewModel = viewModel(),
) {
    val uiState by viewModel.uiState.collectAsState()
    var showLogoutConfirm by remember { mutableStateOf(false) }

    AIDataInsightGradientBackground {
        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.TopCenter,
        ) {
            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .widthIn(max = 680.dp),
                contentPadding = androidx.compose.foundation.layout.PaddingValues(
                    start = 16.dp,
                    top = 8.dp,
                    end = 16.dp,
                    bottom = 28.dp,
                ),
                verticalArrangement = Arrangement.spacedBy(18.dp),
            ) {
                item {
                    SettingNavigationBar(onClose = onClose)
                }

                uiState.errorMessage?.let { message ->
                    item {
                        SettingErrorBanner(
                            message = message,
                            onDismiss = viewModel::dismissError,
                        )
                    }
                }

                val snapshot = uiState.snapshot
                if (snapshot == null && uiState.isLoading) {
                    item {
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(top = 80.dp),
                            contentAlignment = Alignment.Center,
                        ) {
                            CircularProgressIndicator()
                        }
                    }
                }

                snapshot?.let {
                    item {
                        SettingSection(
                            title = "账户",
                            rows = accountRows(it.accountInfo),
                        )
                    }

                    item {
                        SettingSection(
                            title = "关于",
                            rows = aboutRows(it, onOpenPrivacy),
                        )
                    }

                    if (it.capability.canLogout) {
                        item {
                            LogoutRow(
                                isLoggingOut = uiState.isLoggingOut,
                                onClick = { showLogoutConfirm = true },
                            )
                        }
                    }
                }
            }
        }
    }

    if (showLogoutConfirm) {
        AlertDialog(
            onDismissRequest = { showLogoutConfirm = false },
            title = { Text("确认注销并退出系统吗？") },
            confirmButton = {
                TextButton(
                    enabled = !uiState.isLoggingOut,
                    onClick = {
                        showLogoutConfirm = false
                        viewModel.logout(onLogout)
                    },
                ) {
                    Text("确定", color = Color(0xFFFF3B30))
                }
            },
            dismissButton = {
                TextButton(onClick = { showLogoutConfirm = false }) {
                    Text("取消")
                }
            },
        )
    }
}

@Composable
private fun SettingNavigationBar(onClose: () -> Unit) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .heightIn(min = 48.dp),
    ) {
        IconButton(
            onClick = onClose,
            modifier = Modifier.align(Alignment.CenterStart),
        ) {
            Text(
                text = "×",
                style = MaterialTheme.typography.headlineSmall,
                color = AIDataInsightThemeTokens.colors.label.primary,
            )
        }
        Text(
            text = "设置",
            modifier = Modifier.align(Alignment.Center),
            style = MaterialTheme.typography.titleLarge,
            fontWeight = FontWeight.SemiBold,
            color = AIDataInsightThemeTokens.colors.label.primary,
        )
    }
}

private data class SettingRowModel(
    val title: String,
    val detail: String? = null,
    val destructive: Boolean = false,
    val centered: Boolean = false,
    val showsDisclosure: Boolean = false,
    val onClick: (() -> Unit)? = null,
)

private fun accountRows(account: SettingAccountInfo): List<SettingRowModel> {
    return listOf(
        SettingRowModel(title = "昵称", detail = displayText(account.nickname)),
        SettingRowModel(title = "登录名", detail = displayText(account.username)),
        SettingRowModel(title = "手机号", detail = displayText(account.phone)),
    )
}

private fun aboutRows(
    snapshot: SettingSnapshot,
    onOpenPrivacy: () -> Unit,
): List<SettingRowModel> {
    val rows = mutableListOf<SettingRowModel>()
    if (snapshot.capability.canOpenPrivacy) {
        rows += SettingRowModel(
            title = "隐私政策",
            showsDisclosure = true,
            onClick = onOpenPrivacy,
        )
    }
    rows += SettingRowModel(
        title = "App版本",
        detail = snapshot.appVersion,
    )
    return rows
}

private fun displayText(text: String?): String {
    return text?.takeIf { it.isNotBlank() } ?: "未设置"
}

@Composable
private fun SettingSection(
    title: String,
    rows: List<SettingRowModel>,
) {
    Column(verticalArrangement = Arrangement.spacedBy(7.dp)) {
        Text(
            text = title,
            modifier = Modifier.padding(horizontal = 16.dp),
            style = MaterialTheme.typography.labelLarge,
            color = AIDataInsightThemeTokens.colors.label.secondary,
        )
        Surface(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(8.dp)),
            color = AIDataInsightThemeTokens.colors.groupedBackground.secondary,
            shape = RoundedCornerShape(8.dp),
            tonalElevation = 0.dp,
        ) {
            Column {
                rows.forEachIndexed { index, row ->
                    SettingRow(row)
                    if (index < rows.lastIndex) {
                        HorizontalDivider(
                            modifier = Modifier.padding(start = 16.dp),
                            color = AIDataInsightThemeTokens.colors.separator,
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun SettingRow(row: SettingRowModel) {
    val rowModifier = if (row.onClick == null) {
        Modifier
    } else {
        Modifier.clickable(onClick = row.onClick)
    }

    Row(
        modifier = rowModifier
            .fillMaxWidth()
            .heightIn(min = 52.dp)
            .padding(horizontal = 16.dp, vertical = 13.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(
            text = row.title,
            modifier = Modifier.weight(1f),
            style = MaterialTheme.typography.bodyLarge,
            color = if (row.destructive) Color(0xFFFF3B30) else AIDataInsightThemeTokens.colors.label.primary,
            textAlign = if (row.centered) TextAlign.Center else TextAlign.Start,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
        )

        row.detail?.let {
            Text(
                text = it,
                modifier = Modifier
                    .weight(1f, fill = false)
                    .padding(start = 12.dp),
                style = MaterialTheme.typography.bodyMedium,
                color = AIDataInsightThemeTokens.colors.label.secondary,
                textAlign = TextAlign.End,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
        }

        if (row.showsDisclosure) {
            Text(
                text = "›",
                modifier = Modifier.padding(start = 8.dp),
                style = MaterialTheme.typography.titleLarge,
                color = AIDataInsightThemeTokens.colors.label.tertiary,
            )
        }
    }
}

@Composable
private fun LogoutRow(
    isLoggingOut: Boolean,
    onClick: () -> Unit,
) {
    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(8.dp))
            .clickable(enabled = !isLoggingOut, onClick = onClick),
        color = AIDataInsightThemeTokens.colors.groupedBackground.secondary,
        shape = RoundedCornerShape(8.dp),
    ) {
        Text(
            text = if (isLoggingOut) "退出中..." else "退出登录",
            modifier = Modifier
                .fillMaxWidth()
                .heightIn(min = 52.dp)
                .padding(horizontal = 16.dp, vertical = 14.dp),
            style = MaterialTheme.typography.bodyLarge,
            color = Color(0xFFFF3B30),
            textAlign = TextAlign.Center,
        )
    }
}

@Composable
private fun SettingErrorBanner(
    message: String,
    onDismiss: () -> Unit,
) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        color = Color(0xFFFFE8E6),
        shape = RoundedCornerShape(8.dp),
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 14.dp, vertical = 10.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                text = message,
                modifier = Modifier.weight(1f),
                style = MaterialTheme.typography.bodyMedium,
                color = Color(0xFFB42318),
            )
            TextButton(onClick = onDismiss) {
                Text("关闭")
            }
        }
    }
}
