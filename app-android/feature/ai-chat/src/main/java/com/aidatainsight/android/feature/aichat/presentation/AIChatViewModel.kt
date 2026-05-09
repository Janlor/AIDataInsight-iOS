package com.aidatainsight.android.feature.aichat.presentation

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
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
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)
            runCatching { loadTemplateUseCase() }
                .onSuccess { output ->
                    _uiState.value = _uiState.value.copy(
                        templateQuestions = output.questions,
                        isLoading = false,
                    )
                }
                .onFailure { error ->
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
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
        )
        _uiState.value = _uiState.value.copy(
            input = "",
            messages = _uiState.value.messages + userMessage,
            isLoading = true,
            errorMessage = null,
        )

        viewModelScope.launch {
            runCatching {
                when (val result = sendFunctionMessageUseCase(trimmed, _uiState.value.historyId)) {
                    is UseCaseResult.Failure -> {
                        appendAssistantMessage(result.message ?: "未找到可用分析结果")
                    }
                    is UseCaseResult.Success -> handleFunctionOutput(result.value)
                }
            }.onFailure { error ->
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    errorMessage = error.message ?: "发送失败",
                )
            }
        }
    }

    private suspend fun handleFunctionOutput(output: SendFunctionMessageOutput) {
        when (output) {
            is SendFunctionMessageOutput.Intent -> {
                val text = when (output.type.name) {
                    "Time" -> "请选择查询时间范围"
                    "Index" -> "请选择分析指标"
                    else -> "需要补充查询条件"
                }
                appendAssistantMessage(text)
            }
            is SendFunctionMessageOutput.ChartRequest -> {
                _uiState.value = _uiState.value.copy(historyId = output.historyId)
                when (val chartResult = loadChartDataUseCase(output.name, output.historyId, output.arguments)) {
                    is UseCaseResult.Failure -> appendAssistantMessage(
                        chartResult.message ?: "数据分析还在测试阶段，很快就能上线，敬请期待！",
                    )
                    is UseCaseResult.Success -> {
                        val seriesText = chartResult.value.payload.series.joinToString(separator = "\n") { series ->
                            "${series.xAxis}: ${series.values.joinToString()}"
                        }
                        appendAssistantMessage(
                            text = seriesText.ifBlank { "数据分析还在测试阶段，很快就能上线，敬请期待！" },
                            isChart = true,
                        )
                    }
                }
            }
        }
    }

    private fun appendAssistantMessage(text: String, isChart: Boolean = false) {
        val message = AIChatMessageUiModel(
            id = "local-assistant-${System.currentTimeMillis()}",
            role = AIChatMessageRoleUi.Assistant,
            text = text,
            isChart = isChart,
        )
        _uiState.value = _uiState.value.copy(
            messages = _uiState.value.messages + message,
            isLoading = false,
        )
    }

    fun dismissError() {
        _uiState.value = _uiState.value.copy(errorMessage = null)
    }

    fun loadHistory(messages: List<com.aidatainsight.android.core.model.contract.ConversationMessage>) {
        _uiState.value = _uiState.value.copy(
            messages = AIChatHistoryMapper.makeMessages(messages),
            errorMessage = null,
            isLoading = false,
        )
    }
}
