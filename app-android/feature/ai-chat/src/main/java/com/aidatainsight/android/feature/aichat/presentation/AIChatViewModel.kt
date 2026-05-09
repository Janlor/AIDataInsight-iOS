package com.aidatainsight.android.feature.aichat.presentation

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.aidatainsight.android.core.model.contract.AIChatIntentType
import com.aidatainsight.android.core.model.contract.ChartPayload
import com.aidatainsight.android.core.model.contract.FeedbackState
import com.aidatainsight.android.core.model.contract.FunctionName
import com.aidatainsight.android.feature.aichat.application.model.SendFunctionMessageOutput
import com.aidatainsight.android.feature.aichat.application.model.UseCaseResult
import com.aidatainsight.android.feature.aichat.application.usecase.LoadChartDataUseCase
import com.aidatainsight.android.feature.aichat.application.usecase.LoadTemplateUseCase
import com.aidatainsight.android.feature.aichat.application.usecase.SendFunctionMessageUseCase
import com.aidatainsight.android.feature.aichat.data.DefaultAIChatRepository
import com.aidatainsight.android.feature.aichat.domain.AIChatRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class AIChatViewModel(
    repository: AIChatRepository = DefaultAIChatRepository(),
) : ViewModel() {
    private val loadTemplateUseCase = LoadTemplateUseCase(repository)
    private val sendFunctionMessageUseCase = SendFunctionMessageUseCase(repository)
    private val loadChartDataUseCase = LoadChartDataUseCase(repository)

    private val _uiState = MutableStateFlow(AIChatUiState())
    val uiState: StateFlow<AIChatUiState> = _uiState.asStateFlow()

    init {
        refresh()
    }

    fun refresh() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoadingTemplate = true, errorMessage = null)
            runCatching { loadTemplateUseCase() }
                .onSuccess { output ->
                    _uiState.value = _uiState.value.copy(
                        templateQuestions = output.questions,
                        isLoadingTemplate = false,
                    )
                }
                .onFailure { error ->
                    _uiState.value = _uiState.value.copy(
                        isLoadingTemplate = false,
                        errorMessage = error.message ?: "加载失败",
                    )
                }
        }
    }

    fun updateInput(value: String) {
        _uiState.value = _uiState.value.copy(input = value)
    }

    fun useTemplate(question: String) {
        _uiState.value = _uiState.value.copy(input = question)
    }

    fun sendCurrentMessage() {
        send(_uiState.value.input)
    }

    fun send(text: String) {
        val trimmed = text.trim()
        if (trimmed.isEmpty() || _uiState.value.isLoading) return

        val userMessage = AIChatMessageUiModel(
            id = "local-user-${System.currentTimeMillis()}",
            role = AIChatMessageRoleUi.User,
            text = trimmed,
            contentKind = AIChatMessageContentKindUi.Text,
        )
        val loadingMessage = AIChatMessageUiModel(
            id = "local-assistant-loading-${System.currentTimeMillis()}",
            role = AIChatMessageRoleUi.Assistant,
            text = THINKING_TEXT,
            contentKind = AIChatMessageContentKindUi.Loading,
        )
        _uiState.value = _uiState.value.copy(
            input = "",
            messages = _uiState.value.messages + listOf(userMessage, loadingMessage),
            isSending = true,
            errorMessage = null,
        )

        viewModelScope.launch {
            runCatching {
                when (val result = sendFunctionMessageUseCase(trimmed, _uiState.value.historyId)) {
                    is UseCaseResult.Failure -> {
                        replaceProgressMessage(
                            text = result.message ?: "未找到可用分析结果",
                            contentKind = AIChatMessageContentKindUi.Error,
                        )
                    }
                    is UseCaseResult.Success -> handleFunctionOutput(result.value)
                }
            }.onFailure { error ->
                _uiState.value = _uiState.value.copy(
                    isSending = false,
                    isStreaming = false,
                    errorMessage = error.message ?: "发送失败",
                )
            }
        }
    }

    private suspend fun handleFunctionOutput(output: SendFunctionMessageOutput) {
        when (output) {
            is SendFunctionMessageOutput.Intent -> {
                replaceProgressMessage(
                    text = intentText(output.type),
                    contentKind = AIChatMessageContentKindUi.Intent,
                    intentType = output.type,
                )
            }
            is SendFunctionMessageOutput.ChartRequest -> {
                _uiState.value = _uiState.value.copy(historyId = output.historyId)
                when (val chartResult = loadChartDataUseCase(output.name, output.historyId, output.arguments)) {
                    is UseCaseResult.Failure -> replaceProgressMessage(
                        text = chartResult.message ?: CHART_FALLBACK_TEXT,
                        contentKind = AIChatMessageContentKindUi.Error,
                        functionName = output.name,
                    )
                    is UseCaseResult.Success -> {
                        val payload = chartResult.value.payload
                        if (payload.series.isEmpty()) {
                            replaceProgressMessage(
                                text = payload.emptyMessage ?: CHART_FALLBACK_TEXT,
                                contentKind = AIChatMessageContentKindUi.Error,
                                functionName = output.name,
                            )
                        } else {
                            replaceProgressMessage(
                                text = CHART_TITLE_TEXT,
                                contentKind = AIChatMessageContentKindUi.Chart,
                                chartPayload = payload,
                                functionName = output.name,
                            )
                        }
                    }
                }
            }
        }
    }

    private fun replaceProgressMessage(
        text: String,
        contentKind: AIChatMessageContentKindUi,
        intentType: AIChatIntentType? = null,
        chartPayload: ChartPayload? = null,
        functionName: FunctionName? = null,
    ) {
        val message = AIChatMessageUiModel(
            id = "local-assistant-${System.currentTimeMillis()}",
            role = AIChatMessageRoleUi.Assistant,
            text = text,
            contentKind = contentKind,
            intentType = intentType,
            chartPayload = chartPayload,
            feedback = FeedbackState.None,
            functionName = functionName,
        )
        val messages = _uiState.value.messages
        val withoutProgress = if (messages.lastOrNull()?.role == AIChatMessageRoleUi.Assistant &&
            messages.lastOrNull()?.contentKind == AIChatMessageContentKindUi.Loading
        ) {
            messages.dropLast(1)
        } else {
            messages
        }
        _uiState.value = _uiState.value.copy(
            messages = withoutProgress + message,
            isSending = false,
            isStreaming = false,
        )
    }

    private fun intentText(type: AIChatIntentType): String {
        return when (type) {
            AIChatIntentType.Time -> TIME_INTENT_TEXT
            AIChatIntentType.Index -> INDEX_INTENT_TEXT
        }
    }

    fun dismissError() {
        _uiState.value = _uiState.value.copy(errorMessage = null)
    }

    fun loadHistory(messages: List<com.aidatainsight.android.core.model.contract.ConversationMessage>) {
        _uiState.value = _uiState.value.copy(
            messages = AIChatHistoryMapper.makeMessages(messages),
            errorMessage = null,
            isLoadingTemplate = false,
            isSending = false,
            isStreaming = false,
        )
    }

    companion object {
        const val THINKING_TEXT = "智能引擎全力运转，您的答案即将揭晓。"
        const val CHART_TITLE_TEXT = "根据您的查询，以下是分析结果:"
        const val CHART_FALLBACK_TEXT = "数据分析还在测试阶段，很快就能上线，敬请期待！"
        const val TIME_INTENT_TEXT = "请选择查询时间范围"
        const val INDEX_INTENT_TEXT = "请选择分析指标"
    }
}
