package com.aidatainsight.android.feature.aichat.application

import com.aidatainsight.android.core.model.contract.AIChatIntentType
import com.aidatainsight.android.core.model.contract.ChartCommonItem
import com.aidatainsight.android.core.model.contract.FunctionArguments
import com.aidatainsight.android.core.model.contract.FunctionModel
import com.aidatainsight.android.core.model.contract.FunctionName
import com.aidatainsight.android.core.model.contract.HistoryChartDetail
import com.aidatainsight.android.core.model.contract.HistoryRecord
import com.aidatainsight.android.core.model.contract.TemplateQuestionSet
import com.aidatainsight.android.core.model.contract.TimeRangeQuery
import com.aidatainsight.android.core.model.contract.WarehouseQuery
import com.aidatainsight.android.feature.aichat.application.model.SendFunctionMessageOutput
import com.aidatainsight.android.feature.aichat.application.model.UseCaseResult
import com.aidatainsight.android.feature.aichat.application.usecase.LoadChartDataUseCase
import com.aidatainsight.android.feature.aichat.application.usecase.SendFunctionMessageUseCase
import com.aidatainsight.android.feature.aichat.domain.AIChatRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.emptyFlow
import kotlinx.coroutines.runBlocking
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class AIChatUseCaseTest {
    @Test
    fun sendFunctionMessage_returnsTimeIntentWhenTimeRangeStartDateMissing() = runBlocking {
        val useCase = SendFunctionMessageUseCase(
            FakeAIChatRepository(
                functionModel = FunctionModel(
                    historyId = 123,
                    hasTool = true,
                    name = FunctionName.QuerySalesGroupByMonth,
                    arguments = FunctionArguments.TimeRange(
                        TimeRangeQuery(
                            startDate = null,
                            endDate = null,
                            orgId = 1,
                        ),
                    ),
                ),
            ),
        )

        val result = useCase(text = "查销售额", historyId = 123)

        val output = (result as UseCaseResult.Success).value as SendFunctionMessageOutput.Intent
        assertEquals(AIChatIntentType.Time, output.type)
    }

    @Test
    fun loadChartData_rejectsArgumentKindMismatch() = runBlocking {
        val useCase = LoadChartDataUseCase(FakeAIChatRepository())

        val result = useCase(
            name = FunctionName.QuerySalesGroupByMonth,
            historyId = 1,
            arguments = FunctionArguments.Warehouse(WarehouseQuery(orgId = 1)),
        )

        assertTrue(result is UseCaseResult.Failure)
        assertEquals("函数参数类型不匹配。", result.message)
    }

    @Test
    fun loadChartData_mapsChartPayload() = runBlocking {
        val useCase = LoadChartDataUseCase(
            FakeAIChatRepository(
                chartDetail = HistoryChartDetail(
                    funcType = FunctionName.QuerySalesGroupByMonth,
                    chartCommonVoList = listOf(
                        ChartCommonItem(
                            bizId = "2026-01",
                            name = "2026-01",
                            value = 128800.5,
                        ),
                    ),
                ),
            ),
        )

        val result = useCase(
            name = FunctionName.QuerySalesGroupByMonth,
            historyId = 123,
            arguments = FunctionArguments.TimeRange(
                TimeRangeQuery(startDate = "2026-01-01", endDate = "2026-01-31"),
            ),
        )

        val output = (result as UseCaseResult.Success).value
        assertEquals(FunctionName.QuerySalesGroupByMonth, output.payload.functionName)
        assertEquals(128800.5, output.payload.series.single().values.single())
    }
}

private class FakeAIChatRepository(
    private val functionModel: FunctionModel = FunctionModel(),
    private val chartDetail: HistoryChartDetail = HistoryChartDetail(),
) : AIChatRepository {
    override suspend fun loadTemplate(): TemplateQuestionSet = TemplateQuestionSet()

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

