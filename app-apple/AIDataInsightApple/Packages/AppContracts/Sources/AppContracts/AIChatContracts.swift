public struct TemplateQuestionSetContract: Codable, Equatable, Sendable {
    public let questions: [String]

    public init(questions: [String]) {
        self.questions = questions
    }
}

public enum FunctionNameContract: String, Codable, CaseIterable, Sendable {
    case queryArGroupByOrg
    case queryArGroupByCustomer
    case querySalesGroupByOrgAndGoodsType
    case querySalesGroupByMonth
    case querySalesGroupByCustomer
    case queryPurchaseGroupByOrg
    case queryPurchaseGroupByMonth
    case queryPurchaseGroupByCustomer
    case queryStockGroupByOrg
    case queryStockGroupByWarehouse
    case queryInventoryGroupByOrg
    case queryInventoryGroupByWarehouse
    case queryProcurementGroupByOrg
    case queryProcurementGroupByCustomer
    case queryAccountAgeGroupByOrg
    case queryAccountAgeGroupByCustomer
    case queryAccountGroupByAge
    case queryPerformanceType
}

public struct ChartCommonItemContract: Codable, Equatable, Sendable {
    public let bizId: String?
    public let name: String?
    public let value: Double?

    public init(bizId: String?, name: String?, value: Double?) {
        self.bizId = bizId
        self.name = name
        self.value = value
    }
}

public struct HistoryChartDetailContract: Codable, Equatable, Sendable {
    public let historyDetailId: Int?
    public let funcType: FunctionNameContract?
    public let chartCommonVoList: [ChartCommonItemContract]?

    public init(historyDetailId: Int?, funcType: FunctionNameContract?, chartCommonVoList: [ChartCommonItemContract]?) {
        self.historyDetailId = historyDetailId
        self.funcType = funcType
        self.chartCommonVoList = chartCommonVoList
    }
}
