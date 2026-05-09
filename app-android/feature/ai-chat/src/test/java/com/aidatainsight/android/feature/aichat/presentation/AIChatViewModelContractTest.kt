package com.aidatainsight.android.feature.aichat.presentation

import com.aidatainsight.android.core.model.contract.AIChatIntentType
import com.aidatainsight.android.core.model.contract.ChartCommonItem
import com.aidatainsight.android.core.model.contract.ChartUnit
import com.aidatainsight.android.core.model.contract.FunctionArguments
import com.aidatainsight.android.core.model.contract.FunctionModel
import com.aidatainsight.android.core.model.contract.FunctionName
import com.aidatainsight.android.core.model.contract.HistoryChartDetail
import com.aidatainsight.android.core.model.contract.HistoryRecord
import com.aidatainsight.android.core.model.contract.TemplateQuestionSet
import com.aidatainsight.android.core.model.contract.TimeRangeQuery
import com.aidatainsight.android.feature.aichat.domain.AIChatRepository
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.emptyFlow
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotNull
import kotlin.test.assertTrue

@OptIn(ExperimentalCoroutinesApi::class)
class AIChatViewModelContractTest {
    private val dispatcher = StandardTestDispatcher()

    @BeforeTest
    fun setUp() {
        Dispatchers.setMain(dispatcher)
    }

    @AfterTest
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun refresh_loadsTemplateQuestionsWithoutAppendingMessage() = runTest(dispatcher) {
        val viewModel = AIChatViewModel(
            FakeAIChatRepository(
                template = TemplateQuestionSet(
                    questions = listOf("查询本月销售额", "查询库存分布", "查询应收账款"),
                ),
            ),
        )

        advanceUntilIdle()

        val state = viewModel.uiState.value
        assertEquals(listOf("查询本月销售额", "查询库存分布", "查询应收账款"), state.templateQuestions)
        assertEquals(emptyList(), state.messages)
        assertFalse(state.isLoadingTemplate)
        assertFalse(state.canSend)
        assertFalse(state.canClear)
    }

    @Test
    fun sendMessage_appendsUserAndAssistantLoadingMessageImmediately() = runTest(dispatcher) {
        val viewModel = AIChatViewModel(FakeAIChatRepository())
        advanceUntilIdle()

        viewModel.updateInput("查询本月销售额")
        viewModel.sendCurrentMessage()

        val state = viewModel.uiState.value
        assertEquals("", state.inputText)
        assertTrue(state.isSending)
        assertTrue(state.canClear)
        assertEquals(2, state.messages.size)
        assertEquals(AIChatMessageRoleUi.User, state.messages[0].role)
        assertEquals(AIChatMessageContentKindUi.Text, state.messages[0].contentKind)
        assertEquals("查询本月销售额", state.messages[0].text)
        assertEquals(AIChatMessageRoleUi.Assistant, state.messages[1].role)
        assertEquals(AIChatMessageContentKindUi.Loading, state.messages[1].contentKind)
        assertEquals(AIChatViewModel.THINKING_TEXT, state.messages[1].text)
    }

    @Test
    fun timeIntent_replacesLoadingMessageWithIntentMessage() = runTest(dispatcher) {
        val viewModel = AIChatViewModel(
            FakeAIChatRepository(
                functionModel = FunctionModel(
                    historyId = 1001,
                    hasTool = true,
                    name = FunctionName.QuerySalesGroupByMonth,
                    arguments = FunctionArguments.TimeRange(
                        TimeRangeQuery(startDate = null, endDate = null),
                    ),
                ),
            ),
        )
        advanceUntilIdle()

        viewModel.send("查询销售额")
        advanceUntilIdle()

        val state = viewModel.uiState.value
        assertFalse(state.isSending)
        assertEquals(2, state.messages.size)
        val message = state.messages.last()
        assertEquals(AIChatMessageContentKindUi.Intent, message.contentKind)
        assertEquals(AIChatViewModel.TIME_INTENT_TEXT, message.text)
        assertEquals(AIChatIntentType.Time, message.intentType)
    }

    @Test
    fun chartSuccess_replacesLoadingMessageWithChartMessage() = runTest(dispatcher) {
        val viewModel = AIChatViewModel(
            FakeAIChatRepository(
                functionModel = chartFunctionModel(),
                chartDetail = HistoryChartDetail(
                    funcType = FunctionName.QuerySalesGroupByMonth,
                    chartCommonVoList = listOf(
                        ChartCommonItem(
                            bizId = "2026-05",
                            name = "2026-05",
                            value = 128000.0,
                        ),
                    ),
                ),
            ),
        )
        advanceUntilIdle()

        viewModel.send("查询本月销售额")
        advanceUntilIdle()

        val state = viewModel.uiState.value
        assertEquals(1001, state.historyId)
        val message = state.messages.last()
        assertEquals(AIChatMessageContentKindUi.Chart, message.contentKind)
        assertEquals(AIChatViewModel.CHART_TITLE_TEXT, message.text)
        assertEquals(FunctionName.QuerySalesGroupByMonth, message.functionName)
        val payload = assertNotNull(message.chartPayload)
        assertEquals(ChartUnit.Currency, payload.unit)
        assertEquals(128000.0, payload.series.single().values.single())
    }

    @Test
    fun emptyChart_replacesLoadingMessageWithFallbackMessage() = runTest(dispatcher) {
        val viewModel = AIChatViewModel(
            FakeAIChatRepository(
                functionModel = chartFunctionModel(),
                chartDetail = HistoryChartDetail(
                    funcType = FunctionName.QuerySalesGroupByMonth,
                    chartCommonVoList = emptyList(),
                ),
            ),
        )
        advanceUntilIdle()

        viewModel.send("查询本月销售额")
        advanceUntilIdle()

        val message = viewModel.uiState.value.messages.last()
        assertEquals(AIChatMessageContentKindUi.Error, message.contentKind)
        assertEquals(AIChatViewModel.CHART_FALLBACK_TEXT, message.text)
        assertEquals(FunctionName.QuerySalesGroupByMonth, message.functionName)
    }

    private fun chartFunctionModel(): FunctionModel {
        return FunctionModel(
            historyId = 1001,
            hasTool = true,
            name = FunctionName.QuerySalesGroupByMonth,
            arguments = FunctionArguments.TimeRange(
                TimeRangeQuery(startDate = "2026-05-01", endDate = "2026-05-31"),
            ),
        )
    }
}

private class FakeAIChatRepository(
    private val template: TemplateQuestionSet = TemplateQuestionSet(),
    private val functionModel: FunctionModel = FunctionModel(),
    private val chartDetail: HistoryChartDetail = HistoryChartDetail(),
) : AIChatRepository {
    override suspend fun loadTemplate(): TemplateQuestionSet = template

    override suspend fun loadHistoryDetail(historyId: Int): HistoryRecord = HistoryRecord(id = historyId)

    override suspend fun sendFunctionMessage(text: String, historyId: Int?): FunctionModel = functionModel

    override suspend fun loadChartData(
        name: FunctionName,
        historyId: Int,
        arguments: FunctionArguments,
    ): HistoryChartDetail = chartDetail

    override suspend fun sendLikeFeedback(historyDetailId: Int, like: String) = Unit

    override fun streamMessage(text: String): Flow<String> = emptyFlow()
}
