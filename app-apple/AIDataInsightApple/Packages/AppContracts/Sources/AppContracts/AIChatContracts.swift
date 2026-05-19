public struct TemplateQuestionSetContract: Codable, Equatable, Sendable {
    public let questions: [String]

    public init(questions: [String]) {
        self.questions = questions
    }
}

public struct BasicQueryContract: Codable, Equatable, Sendable {
    public let orgId: Int?
    public let customerName: String?
    public let orderType: String?
    public let `operator`: String?
    public let value: Double?

    public init(orgId: Int?, customerName: String?, orderType: String?, operator: String?, value: Double?) {
        self.orgId = orgId
        self.customerName = customerName
        self.orderType = orderType
        self.operator = `operator`
        self.value = value
    }
}

public struct TimeRangeQueryContract: Codable, Equatable, Sendable {
    public let startDate: String?
    public let endDate: String?
    public let orgId: Int?
    public let customerName: String?
    public let goodsType: Int?
    public let orderType: String?
    public let `operator`: String?
    public let value: Double?

    public init(startDate: String?, endDate: String?, orgId: Int?, customerName: String?, goodsType: Int?, orderType: String?, operator: String?, value: Double?) {
        self.startDate = startDate
        self.endDate = endDate
        self.orgId = orgId
        self.customerName = customerName
        self.goodsType = goodsType
        self.orderType = orderType
        self.operator = `operator`
        self.value = value
    }
}

public struct WarehouseQueryContract: Codable, Equatable, Sendable {
    public let orgId: Int?
    public let warehouseName: String?
    public let goodsType: Int?
    public let orderType: String?
    public let `operator`: String?
    public let value: Double?

    public init(orgId: Int?, warehouseName: String?, goodsType: Int?, orderType: String?, operator: String?, value: Double?) {
        self.orgId = orgId
        self.warehouseName = warehouseName
        self.goodsType = goodsType
        self.orderType = orderType
        self.operator = `operator`
        self.value = value
    }
}

public struct AccountAgeQueryContract: Codable, Equatable, Sendable {
    public let orgId: Int?
    public let customerName: String?
    public let orderType: String?
    public let valueArray: [String]?

    public init(orgId: Int?, customerName: String?, orderType: String?, valueArray: [String]?) {
        self.orgId = orgId
        self.customerName = customerName
        self.orderType = orderType
        self.valueArray = valueArray
    }
}

public struct PerformanceTypeQueryContract: Codable, Equatable, Sendable {
    public let indexType: String?

    public init(indexType: String?) {
        self.indexType = indexType
    }
}

public enum FunctionArgumentsContract: Codable, Equatable, Sendable {
    case basic(BasicQueryContract)
    case timeRange(TimeRangeQueryContract)
    case warehouse(WarehouseQueryContract)
    case accountAge(AccountAgeQueryContract)
    case performanceType(PerformanceTypeQueryContract)

    public enum Kind: String, Codable, Sendable {
        case basic
        case timeRange
        case warehouse
        case accountAge
        case performanceType
    }

    public var kind: Kind {
        switch self {
        case .basic:
            .basic
        case .timeRange:
            .timeRange
        case .warehouse:
            .warehouse
        case .accountAge:
            .accountAge
        case .performanceType:
            .performanceType
        }
    }

    private enum CodingKeys: String, CodingKey {
        case kind
        case value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .kind)
        switch kind {
        case .basic:
            self = .basic(try container.decode(BasicQueryContract.self, forKey: .value))
        case .timeRange:
            self = .timeRange(try container.decode(TimeRangeQueryContract.self, forKey: .value))
        case .warehouse:
            self = .warehouse(try container.decode(WarehouseQueryContract.self, forKey: .value))
        case .accountAge:
            self = .accountAge(try container.decode(AccountAgeQueryContract.self, forKey: .value))
        case .performanceType:
            self = .performanceType(try container.decode(PerformanceTypeQueryContract.self, forKey: .value))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(kind, forKey: .kind)
        switch self {
        case .basic(let value):
            try container.encode(value, forKey: .value)
        case .timeRange(let value):
            try container.encode(value, forKey: .value)
        case .warehouse(let value):
            try container.encode(value, forKey: .value)
        case .accountAge(let value):
            try container.encode(value, forKey: .value)
        case .performanceType(let value):
            try container.encode(value, forKey: .value)
        }
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

public struct AccountAgeGroupItemContract: Codable, Equatable, Sendable {
    public let name: String?
    public let valueList: [Double]?
    public let labelList: [String]?
    public let msg: String?
    public let chartType: String?

    public init(name: String?, valueList: [Double]?, labelList: [String]?, msg: String?, chartType: String?) {
        self.name = name
        self.valueList = valueList
        self.labelList = labelList
        self.msg = msg
        self.chartType = chartType
    }
}

public struct HistoryChartDetailContract: Codable, Equatable, Sendable {
    public let historyDetailId: Int?
    public let funcType: FunctionNameContract?
    public let chartCommonVoList: [ChartCommonItemContract]?
    public let accountAgeGroupVoList: [AccountAgeGroupItemContract]?

    public init(historyDetailId: Int?, funcType: FunctionNameContract?, chartCommonVoList: [ChartCommonItemContract]?, accountAgeGroupVoList: [AccountAgeGroupItemContract]? = nil) {
        self.historyDetailId = historyDetailId
        self.funcType = funcType
        self.chartCommonVoList = chartCommonVoList
        self.accountAgeGroupVoList = accountAgeGroupVoList
    }
}

public struct FunctionModelContract: Codable, Equatable, Sendable {
    public let historyId: Int?
    public let hasTool: Bool?
    public let name: FunctionNameContract?
    public let msg: String?
    public let arguments: FunctionArgumentsContract?

    public init(historyId: Int?, hasTool: Bool?, name: FunctionNameContract?, msg: String?, arguments: FunctionArgumentsContract?) {
        self.historyId = historyId
        self.hasTool = hasTool
        self.name = name
        self.msg = msg
        self.arguments = arguments
    }
}

public struct LikeHistoryDetailRequestContract: Codable, Equatable, Sendable {
    public let historyDetailId: Int
    public let like: String

    public init(historyDetailId: Int, like: String) {
        self.historyDetailId = historyDetailId
        self.like = like
    }
}
