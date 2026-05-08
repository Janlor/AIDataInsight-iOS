package com.aidatainsight.android.core.network.service

import com.aidatainsight.android.core.model.contract.AccountAgeQuery
import com.aidatainsight.android.core.model.contract.BasicQuery
import com.aidatainsight.android.core.model.contract.FunctionArguments
import com.aidatainsight.android.core.model.contract.FunctionName
import com.aidatainsight.android.core.model.contract.HistoryChartDetail
import com.aidatainsight.android.core.model.contract.PerformanceTypeQuery
import com.aidatainsight.android.core.model.contract.TimeRangeQuery
import com.aidatainsight.android.core.model.contract.WarehouseQuery
import com.aidatainsight.android.core.network.client.AIDataInsightApiClient

interface ChartRemoteService {
    suspend fun loadChartData(
        functionName: FunctionName,
        historyId: Int,
        arguments: FunctionArguments,
    ): HistoryChartDetail?
}

class KtorChartRemoteService(
    private val apiClient: AIDataInsightApiClient,
) : ChartRemoteService {
    override suspend fun loadChartData(
        functionName: FunctionName,
        historyId: Int,
        arguments: FunctionArguments,
    ): HistoryChartDetail? {
        require(functionName.argumentKind == arguments.kind) {
            "FunctionArguments.kind must match FunctionName.argumentKind."
        }

        return apiClient.get(
            path = "/chart/${functionName.rawValue}",
            query = arguments.toQueryParameters() + mapOf("historyId" to historyId),
        )
    }
}

private fun FunctionArguments.toQueryParameters(): Map<String, Any?> {
    return when (this) {
        is FunctionArguments.Basic -> value.toQueryParameters()
        is FunctionArguments.TimeRange -> value.toQueryParameters()
        is FunctionArguments.Warehouse -> value.toQueryParameters()
        is FunctionArguments.AccountAge -> value.toQueryParameters()
        is FunctionArguments.PerformanceType -> value.toQueryParameters()
    }
}

private fun BasicQuery.toQueryParameters(): Map<String, Any?> = mapOf(
    "orgId" to orgId,
    "customerName" to customerName,
    "orderType" to orderType,
    "operator" to operator,
    "value" to value,
)

private fun TimeRangeQuery.toQueryParameters(): Map<String, Any?> = mapOf(
    "startDate" to startDate,
    "endDate" to endDate,
    "orgId" to orgId,
    "customerName" to customerName,
    "goodsType" to goodsType,
    "orderType" to orderType,
    "operator" to operator,
    "value" to value,
)

private fun WarehouseQuery.toQueryParameters(): Map<String, Any?> = mapOf(
    "orgId" to orgId,
    "warehouseName" to warehouseName,
    "goodsType" to goodsType,
    "orderType" to orderType,
    "operator" to operator,
    "value" to value,
)

private fun AccountAgeQuery.toQueryParameters(): Map<String, Any?> = mapOf(
    "orgId" to orgId,
    "customerName" to customerName,
    "orderType" to orderType,
    "valueArray" to valueArray,
)

private fun PerformanceTypeQuery.toQueryParameters(): Map<String, Any?> = mapOf(
    "indexType" to indexType,
)

