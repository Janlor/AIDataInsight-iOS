package com.aidatainsight.android.feature.login.ui

import androidx.compose.foundation.Image
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Snackbar
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.aidatainsight.android.core.ui.layout.AIDataInsightGradientBackground
import com.aidatainsight.android.core.ui.theme.AIDataInsightThemeTokens
import com.aidatainsight.android.feature.login.R
import com.aidatainsight.android.feature.login.presentation.LoginUiState
import com.aidatainsight.android.feature.login.presentation.LoginViewModel

@Composable
fun LoginScreen(
    onLoginSuccess: () -> Unit,
    onOpenPrivacy: () -> Unit = {},
    viewModel: LoginViewModel = viewModel(),
) {
    val uiState by viewModel.uiState.collectAsState()
    AIDataInsightGradientBackground {
        val isLandscapeLayout = maxWidth > maxHeight && maxWidth >= 600.dp

        if (isLandscapeLayout) {
            LandscapeLoginContent(
                uiState = uiState,
                onUsernameChange = viewModel::updateUsername,
                onPasswordChange = viewModel::updatePassword,
                onTogglePrivacy = viewModel::togglePrivacyAccepted,
                onLogin = { viewModel.login(onLoginSuccess) },
                onOpenPrivacy = onOpenPrivacy,
                modifier = Modifier.align(Alignment.TopCenter),
                minHeight = maxHeight,
            )
        } else {
            PortraitLoginContent(
                uiState = uiState,
                onUsernameChange = viewModel::updateUsername,
                onPasswordChange = viewModel::updatePassword,
                onTogglePrivacy = viewModel::togglePrivacyAccepted,
                onLogin = { viewModel.login(onLoginSuccess) },
                onOpenPrivacy = onOpenPrivacy,
                modifier = Modifier.align(Alignment.TopCenter),
                minHeight = maxHeight,
            )
        }
    }
}

@Composable
private fun PortraitLoginContent(
    uiState: LoginUiState,
    onUsernameChange: (String) -> Unit,
    onPasswordChange: (String) -> Unit,
    onTogglePrivacy: () -> Unit,
    onLogin: () -> Unit,
    onOpenPrivacy: () -> Unit,
    modifier: Modifier = Modifier,
    minHeight: androidx.compose.ui.unit.Dp,
) {
    val agreementTopSpacing = (minHeight - 560.dp).coerceAtLeast(24.dp)

    Column(
        modifier = modifier
            .widthIn(max = 430.dp)
            .fillMaxWidth()
            .heightIn(min = minHeight)
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 38.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Spacer(modifier = Modifier.height(60.dp))

        BrandHeader()

        Spacer(modifier = Modifier.height(105.dp))

        LoginForm(
            uiState = uiState,
            onUsernameChange = onUsernameChange,
            onPasswordChange = onPasswordChange,
            onLogin = onLogin,
        )

        Spacer(modifier = Modifier.height(agreementTopSpacing))

        PrivacyAgreement(
            checked = uiState.isPrivacyAccepted,
            onToggle = onTogglePrivacy,
            onOpenPrivacy = onOpenPrivacy,
        )

        Spacer(modifier = Modifier.height(12.dp))
    }
}

@Composable
private fun LandscapeLoginContent(
    uiState: LoginUiState,
    onUsernameChange: (String) -> Unit,
    onPasswordChange: (String) -> Unit,
    onTogglePrivacy: () -> Unit,
    onLogin: () -> Unit,
    onOpenPrivacy: () -> Unit,
    modifier: Modifier = Modifier,
    minHeight: androidx.compose.ui.unit.Dp,
) {
    Column(
        modifier = modifier
            .widthIn(max = 820.dp)
            .fillMaxWidth()
            .heightIn(min = minHeight)
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 40.dp, vertical = 24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(56.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            BrandHeader(
                modifier = Modifier.weight(0.9f),
                horizontalAlignment = Alignment.Start,
                textAlign = TextAlign.Start,
            )

            Column(
                modifier = Modifier
                    .weight(1f)
                    .widthIn(max = 390.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                LoginForm(
                    uiState = uiState,
                    onUsernameChange = onUsernameChange,
                    onPasswordChange = onPasswordChange,
                    onLogin = onLogin,
                )

                Spacer(modifier = Modifier.height(28.dp))

                PrivacyAgreement(
                    checked = uiState.isPrivacyAccepted,
                    onToggle = onTogglePrivacy,
                    onOpenPrivacy = onOpenPrivacy,
                )
            }
        }
    }
}

@Composable
private fun BrandHeader(
    modifier: Modifier = Modifier,
    horizontalAlignment: Alignment.Horizontal = Alignment.CenterHorizontally,
    textAlign: TextAlign = TextAlign.Center,
) {
    val colors = AIDataInsightThemeTokens.colors
    Column(
        modifier = modifier,
        horizontalAlignment = horizontalAlignment,
    ) {
        AppIcon()

        Spacer(modifier = Modifier.height(30.dp))

        Text(
            text = "AI数据分析助手",
            color = colors.label.primary,
            style = MaterialTheme.typography.headlineMedium,
            fontWeight = FontWeight.SemiBold,
            textAlign = textAlign,
        )

        Spacer(modifier = Modifier.height(10.dp))

        Text(
            text = "让工作更流畅更轻松",
            color = colors.label.secondary,
            style = MaterialTheme.typography.bodyMedium,
            textAlign = textAlign,
        )
    }
}

@Composable
private fun AppIcon() {
    Image(
        painter = painterResource(R.drawable.ic_login_app),
        contentDescription = null,
        modifier = Modifier
            .size(72.dp)
            .clip(RoundedCornerShape(16.dp)),
    )
}

@Composable
private fun LoginForm(
    uiState: LoginUiState,
    onUsernameChange: (String) -> Unit,
    onPasswordChange: (String) -> Unit,
    onLogin: () -> Unit,
) {
    val colors = AIDataInsightThemeTokens.colors
    UnderlinedLoginField(
        value = uiState.username,
        onValueChange = onUsernameChange,
        placeholder = "请输入账号",
        enabled = !uiState.isLoading,
        imeAction = ImeAction.Next,
    )

    Spacer(modifier = Modifier.height(20.dp))

    UnderlinedLoginField(
        value = uiState.password,
        onValueChange = onPasswordChange,
        placeholder = "请输入密码",
        enabled = !uiState.isLoading,
        isPassword = true,
        imeAction = ImeAction.Done,
        onDone = onLogin,
    )

    Spacer(modifier = Modifier.height(30.dp))

    Button(
        onClick = onLogin,
        modifier = Modifier
            .fillMaxWidth()
            .height(52.dp),
        enabled = uiState.canLogin,
        shape = RoundedCornerShape(12.dp),
        colors = ButtonDefaults.buttonColors(
            containerColor = MaterialTheme.colorScheme.primary,
            disabledContainerColor = colors.label.quinary,
            contentColor = Color.White,
            disabledContentColor = Color.White,
        ),
    ) {
        if (uiState.isLoading) {
            CircularProgressIndicator(
                modifier = Modifier.size(18.dp),
                strokeWidth = 2.dp,
                color = Color.White,
            )
            Spacer(modifier = Modifier.width(8.dp))
        }
        Text(
            text = if (uiState.isLoading) "登录中…" else "登录",
            fontSize = 17.sp,
            fontWeight = FontWeight.SemiBold,
        )
    }

    uiState.errorMessage?.let { message ->
        Spacer(modifier = Modifier.height(12.dp))
        Snackbar(
            containerColor = MaterialTheme.colorScheme.error,
            contentColor = Color.White,
        ) {
            Text(message)
        }
    }
}

@Composable
private fun UnderlinedLoginField(
    value: String,
    onValueChange: (String) -> Unit,
    placeholder: String,
    enabled: Boolean,
    modifier: Modifier = Modifier,
    isPassword: Boolean = false,
    imeAction: ImeAction = ImeAction.Done,
    onDone: () -> Unit = {},
) {
    val colors = AIDataInsightThemeTokens.colors
    Column(modifier = modifier.fillMaxWidth()) {
        BasicTextField(
            value = value,
            onValueChange = onValueChange,
            enabled = enabled,
            singleLine = true,
            textStyle = TextStyle(
                color = colors.label.primary,
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold,
            ),
            visualTransformation = if (isPassword) PasswordVisualTransformation() else VisualTransformation.None,
            keyboardOptions = KeyboardOptions(
                keyboardType = if (isPassword) KeyboardType.Password else KeyboardType.Text,
                imeAction = imeAction,
            ),
            keyboardActions = KeyboardActions(onDone = { onDone() }),
            decorationBox = { innerTextField ->
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(45.dp),
                    contentAlignment = Alignment.CenterStart,
                ) {
                    if (value.isEmpty()) {
                        Text(
                            text = placeholder,
                            color = colors.label.quaternary,
                            style = MaterialTheme.typography.bodyMedium,
                        )
                    }
                    innerTextField()
                }
            },
        )
        HorizontalDivider(color = colors.separator, thickness = 1.dp)
    }
}

@Composable
private fun PrivacyAgreement(
    checked: Boolean,
    onToggle: () -> Unit,
    onOpenPrivacy: () -> Unit,
) {
    val colors = AIDataInsightThemeTokens.colors
    val checkboxInteractionSource = remember { MutableInteractionSource() }
    Row(
        modifier = Modifier.widthIn(max = 320.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.Center,
    ) {
        Image(
            painter = painterResource(
                if (checked) R.drawable.ic_checkbox_selected else R.drawable.ic_checkbox_normal,
            ),
            contentDescription = null,
            modifier = Modifier
                .size(18.dp)
                .clickable(
                    interactionSource = checkboxInteractionSource,
                    indication = null,
                    onClick = onToggle,
                ),
        )

        Spacer(modifier = Modifier.width(8.dp))

        Text(
            text = "已阅读并同意",
            color = colors.label.secondary,
            style = MaterialTheme.typography.bodySmall,
        )
        Text(
            text = "《隐私政策》",
            color = MaterialTheme.colorScheme.primary,
            style = MaterialTheme.typography.bodySmall,
            modifier = Modifier.clickable(onClick = onOpenPrivacy),
        )
    }
}
