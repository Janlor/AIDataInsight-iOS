// Generated from docs/cross-platform/contracts. Do not edit by hand.
package com.aidatainsight.android.core.model.contract

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

object MockApiEnvironment {
    const val DefaultBaseUrl: String = "https://m1.apifoxmock.com/m1/3174267-1700689-default"
}

object AIChatEndpoint {
    const val StreamPath: String = "/stream"
}

@Serializable
data class ApiEnvironment(
    val name: String,
    val baseUrl: String,
    val description: String? = null,
)

@Serializable
data class AccountSession(
    val accessToken: String? = null,
    val refreshToken: String? = null,
    val orgId: Int? = null,
    val username: String? = null,
    val isLogin: Boolean = false,
)

@Serializable
data class AccountUser(
    val id: Int? = null,
    val username: String? = null,
    val nickname: String? = null,
    val phone: String? = null,
)

@Serializable
enum class AIHomeDestination {
    Chat,
    History,
    Settings,
}

@Serializable
enum class AIHomePanel {
    None,
    History,
}

@Serializable
data class AIHomeSession(
    val isAuthenticated: Boolean,
    val entryDestination: AIHomeDestination,
    val selectedHistoryId: Int? = null,
    val activePanel: AIHomePanel,
)

@Serializable
enum class AIHomeCommand {
    OpenAIHome,
    OpenHistoryPanel,
    CloseHistoryPanel,
    SelectHistoryConversation,
    StartNewConversation,
    OpenSettings,
    LogoutToLogin,
}

@Serializable
data class SettingAccountInfo(
    val nickname: String? = null,
    val username: String? = null,
    val phone: String? = null,
)

@Serializable
data class SettingCapability(
    val canUpdatePassword: Boolean,
    val canOpenPrivacy: Boolean,
    val canLogout: Boolean,
)

@Serializable
data class SettingSnapshot(
    val accountInfo: SettingAccountInfo,
    val capability: SettingCapability,
    val appVersion: String,
)

@Serializable
enum class HistoryDetailType(val rawValue: String) {
    @SerialName("1")
    Question("1"),

    @SerialName("2")
    Answer("2"),
}

@Serializable
enum class HistoryContentType(val rawValue: String) {
    @SerialName("1")
    Ai("1"),

    @SerialName("2")
    Chart("2"),
}

@Serializable
data class HistoryDetail(
    val id: Int? = null,
    val historyId: Int? = null,
    val type: HistoryDetailType? = null,
    val contentType: HistoryContentType? = null,
    val content: String? = null,
    val isLike: String? = null,
    val createTime: String? = null,
    val updateTime: String? = null,
)

@Serializable
data class HistoryRecord(
    val id: Int? = null,
    val name: String? = null,
    val createId: Int? = null,
    val updateId: Int? = null,
    val createName: String? = null,
    val updateName: String? = null,
    val createTime: String? = null,
    val updateTime: String? = null,
    val detailList: List<HistoryDetail>? = null,
)

@Serializable
data class RecordPage(
    val currentPage: Int? = null,
    val pageSize: Int? = null,
    val total: Int? = null,
    val pages: Int? = null,
    val cacheKey: String? = null,
    val records: List<HistoryRecord>? = null,
)

@Serializable
data class TemplateQuestionSet(
    val questions: List<String> = emptyList(),
)

@Serializable
enum class FunctionArgumentKind {
    Basic,
    TimeRange,
    Warehouse,
    AccountAge,
    PerformanceType,
}

@Serializable
enum class FunctionName(val rawValue: String) {
    @SerialName("queryArGroupByOrg")
    QueryArGroupByOrg("queryArGroupByOrg"),
    @SerialName("queryArGroupByCustomer")
    QueryArGroupByCustomer("queryArGroupByCustomer"),
    @SerialName("querySalesGroupByOrgAndGoodsType")
    QuerySalesGroupByOrgAndGoodsType("querySalesGroupByOrgAndGoodsType"),
    @SerialName("querySalesGroupByMonth")
    QuerySalesGroupByMonth("querySalesGroupByMonth"),
    @SerialName("querySalesGroupByCustomer")
    QuerySalesGroupByCustomer("querySalesGroupByCustomer"),
    @SerialName("queryPurchaseGroupByOrg")
    QueryPurchaseGroupByOrg("queryPurchaseGroupByOrg"),
    @SerialName("queryPurchaseGroupByMonth")
    QueryPurchaseGroupByMonth("queryPurchaseGroupByMonth"),
    @SerialName("queryPurchaseGroupByCustomer")
    QueryPurchaseGroupByCustomer("queryPurchaseGroupByCustomer"),
    @SerialName("queryStockGroupByOrg")
    QueryStockGroupByOrg("queryStockGroupByOrg"),
    @SerialName("queryStockGroupByWarehouse")
    QueryStockGroupByWarehouse("queryStockGroupByWarehouse"),
    @SerialName("queryInventoryGroupByOrg")
    QueryInventoryGroupByOrg("queryInventoryGroupByOrg"),
    @SerialName("queryInventoryGroupByWarehouse")
    QueryInventoryGroupByWarehouse("queryInventoryGroupByWarehouse"),
    @SerialName("queryProcurementGroupByOrg")
    QueryProcurementGroupByOrg("queryProcurementGroupByOrg"),
    @SerialName("queryProcurementGroupByCustomer")
    QueryProcurementGroupByCustomer("queryProcurementGroupByCustomer"),
    @SerialName("queryAccountAgeGroupByOrg")
    QueryAccountAgeGroupByOrg("queryAccountAgeGroupByOrg"),
    @SerialName("queryAccountAgeGroupByCustomer")
    QueryAccountAgeGroupByCustomer("queryAccountAgeGroupByCustomer"),
    @SerialName("queryAccountGroupByAge")
    QueryAccountGroupByAge("queryAccountGroupByAge"),
    @SerialName("queryPerformanceType")
    QueryPerformanceType("queryPerformanceType");

    val argumentKind: FunctionArgumentKind
        get() = when (this) {
            QueryArGroupByOrg -> FunctionArgumentKind.Basic
            QueryArGroupByCustomer -> FunctionArgumentKind.Basic
            QuerySalesGroupByOrgAndGoodsType -> FunctionArgumentKind.TimeRange
            QuerySalesGroupByMonth -> FunctionArgumentKind.TimeRange
            QuerySalesGroupByCustomer -> FunctionArgumentKind.TimeRange
            QueryPurchaseGroupByOrg -> FunctionArgumentKind.TimeRange
            QueryPurchaseGroupByMonth -> FunctionArgumentKind.TimeRange
            QueryPurchaseGroupByCustomer -> FunctionArgumentKind.TimeRange
            QueryStockGroupByOrg -> FunctionArgumentKind.Warehouse
            QueryStockGroupByWarehouse -> FunctionArgumentKind.Warehouse
            QueryInventoryGroupByOrg -> FunctionArgumentKind.Warehouse
            QueryInventoryGroupByWarehouse -> FunctionArgumentKind.Warehouse
            QueryProcurementGroupByOrg -> FunctionArgumentKind.Warehouse
            QueryProcurementGroupByCustomer -> FunctionArgumentKind.Warehouse
            QueryAccountAgeGroupByOrg -> FunctionArgumentKind.AccountAge
            QueryAccountAgeGroupByCustomer -> FunctionArgumentKind.AccountAge
            QueryAccountGroupByAge -> FunctionArgumentKind.Basic
            QueryPerformanceType -> FunctionArgumentKind.PerformanceType
        }

    companion object {
        fun fromRawValue(rawValue: String): FunctionName? = entries.firstOrNull { it.rawValue == rawValue }
    }
}

@Serializable
data class BasicQuery(
    val orgId: Int? = null,
    val customerName: String? = null,
    val orderType: String? = null,
    val operator: String? = null,
    val value: Double? = null,
)

@Serializable
data class TimeRangeQuery(
    val startDate: String? = null,
    val endDate: String? = null,
    val orgId: Int? = null,
    val customerName: String? = null,
    val goodsType: Int? = null,
    val orderType: String? = null,
    val operator: String? = null,
    val value: Double? = null,
)

@Serializable
data class WarehouseQuery(
    val orgId: Int? = null,
    val warehouseName: String? = null,
    val goodsType: Int? = null,
    val orderType: String? = null,
    val operator: String? = null,
    val value: Double? = null,
)

@Serializable
data class AccountAgeQuery(
    val orgId: Int? = null,
    val customerName: String? = null,
    val orderType: String? = null,
    val valueArray: List<String>? = null,
)

@Serializable
data class PerformanceTypeQuery(
    val indexType: String? = null,
)

@Serializable
sealed interface FunctionArguments {
    val kind: FunctionArgumentKind

    @Serializable
    data class Basic(val value: BasicQuery) : FunctionArguments {
        override val kind: FunctionArgumentKind = FunctionArgumentKind.Basic
    }

    @Serializable
    data class TimeRange(val value: TimeRangeQuery) : FunctionArguments {
        override val kind: FunctionArgumentKind = FunctionArgumentKind.TimeRange
    }

    @Serializable
    data class Warehouse(val value: WarehouseQuery) : FunctionArguments {
        override val kind: FunctionArgumentKind = FunctionArgumentKind.Warehouse
    }

    @Serializable
    data class AccountAge(val value: AccountAgeQuery) : FunctionArguments {
        override val kind: FunctionArgumentKind = FunctionArgumentKind.AccountAge
    }

    @Serializable
    data class PerformanceType(val value: PerformanceTypeQuery) : FunctionArguments {
        override val kind: FunctionArgumentKind = FunctionArgumentKind.PerformanceType
    }
}

@Serializable
data class FunctionModel(
    val historyId: Int? = null,
    val hasTool: Boolean? = null,
    val name: FunctionName? = null,
    val msg: String? = null,
    val arguments: FunctionArguments? = null,
)

@Serializable
data class ChartCommonItem(
    val bizId: String? = null,
    val name: String? = null,
    val value: Double? = null,
)

@Serializable
data class AccountAgeGroupItem(
    val name: String? = null,
    val valueList: List<Double>? = null,
    val labelList: List<String>? = null,
    val msg: String? = null,
    val chartType: String? = null,
)

@Serializable
data class HistoryChartDetail(
    val funcType: FunctionName? = null,
    val chartCommonVoList: List<ChartCommonItem>? = null,
    val accountAgeGroupVoList: List<AccountAgeGroupItem>? = null,
)

@Serializable
enum class ConversationRole {
    User,
    Assistant,
}

@Serializable
enum class ConversationContentKind {
    Welcome,
    Text,
    Intent,
    Chart,
}

@Serializable
enum class AIChatIntentType {
    Time,
    Index,
}

@Serializable
enum class FeedbackState {
    Liked,
    Disliked,
    None,
    Unknown,
}

@Serializable
enum class ChartUnit {
    Currency,
    Ton,
}

@Serializable
data class ChartSeries(
    val xAxis: String,
    val labels: List<String>,
    val values: List<Double>,
)

@Serializable
data class ChartPayload(
    val functionName: FunctionName? = null,
    val unit: ChartUnit,
    val series: List<ChartSeries>,
    val emptyMessage: String? = null,
)

@Serializable
data class ConversationMessage(
    val id: String,
    val role: ConversationRole,
    val contentKind: ConversationContentKind,
    val text: String? = null,
    val intentType: AIChatIntentType? = null,
    val chartPayload: ChartPayload? = null,
    val feedback: FeedbackState = FeedbackState.None,
    val historyDetailId: Int? = null,
    val functionName: FunctionName? = null,
)
