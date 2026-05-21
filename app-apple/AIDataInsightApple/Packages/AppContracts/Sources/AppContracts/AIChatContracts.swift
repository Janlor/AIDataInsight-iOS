import Foundation

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

    public static func decode(from decoder: Decoder, name: FunctionNameContract?) throws -> FunctionArgumentsContract {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            guard let data = string.data(using: .utf8), let kind = name?.argumentKind else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid function arguments JSON string."
                )
            }
            return try decode(kind: kind, from: data)
        }

        if let wrapped = try? FunctionArgumentsContract(from: decoder) {
            return wrapped
        }

        guard let kind = name?.argumentKind else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Function arguments require a function name when decoded without kind."
            )
        }
        return try decode(kind: kind, from: decoder)
    }

    private static func decode(kind: Kind, from data: Data) throws -> FunctionArgumentsContract {
        let decoder = JSONDecoder()
        switch kind {
        case .basic:
            return .basic(try decoder.decode(BasicQueryContract.self, from: data))
        case .timeRange:
            return .timeRange(try decoder.decode(TimeRangeQueryContract.self, from: data))
        case .warehouse:
            return .warehouse(try decoder.decode(WarehouseQueryContract.self, from: data))
        case .accountAge:
            return .accountAge(try decoder.decode(AccountAgeQueryContract.self, from: data))
        case .performanceType:
            return .performanceType(try decoder.decode(PerformanceTypeQueryContract.self, from: data))
        }
    }

    private static func decode(kind: Kind, from decoder: Decoder) throws -> FunctionArgumentsContract {
        switch kind {
        case .basic:
            return .basic(try BasicQueryContract(from: decoder))
        case .timeRange:
            return .timeRange(try TimeRangeQueryContract(from: decoder))
        case .warehouse:
            return .warehouse(try WarehouseQueryContract(from: decoder))
        case .accountAge:
            return .accountAge(try AccountAgeQueryContract(from: decoder))
        case .performanceType:
            return .performanceType(try PerformanceTypeQueryContract(from: decoder))
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

    public var argumentKind: FunctionArgumentsContract.Kind {
        switch self {
        case .queryArGroupByOrg, .queryArGroupByCustomer, .queryAccountGroupByAge:
            return .basic
        case .querySalesGroupByOrgAndGoodsType, .querySalesGroupByMonth, .querySalesGroupByCustomer,
             .queryPurchaseGroupByOrg, .queryPurchaseGroupByMonth, .queryPurchaseGroupByCustomer:
            return .timeRange
        case .queryStockGroupByOrg, .queryStockGroupByWarehouse, .queryInventoryGroupByOrg,
             .queryInventoryGroupByWarehouse, .queryProcurementGroupByOrg, .queryProcurementGroupByCustomer:
            return .warehouse
        case .queryAccountAgeGroupByOrg, .queryAccountAgeGroupByCustomer:
            return .accountAge
        case .queryPerformanceType:
            return .performanceType
        }
    }
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

    private enum CodingKeys: String, CodingKey {
        case historyId
        case hasTool
        case name
        case msg
        case arguments
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        historyId = try container.decodeIfPresent(Int.self, forKey: .historyId)
        hasTool = try container.decodeIfPresent(Bool.self, forKey: .hasTool)
        name = try container.decodeIfPresent(FunctionNameContract.self, forKey: .name)
        msg = try container.decodeIfPresent(String.self, forKey: .msg)
        let hasArguments: Bool
        if container.contains(.arguments) {
            hasArguments = !(try container.decodeNil(forKey: .arguments))
        } else {
            hasArguments = false
        }
        if hasArguments {
            arguments = try FunctionArgumentsContract.decode(
                from: container.superDecoder(forKey: .arguments),
                name: name
            )
        } else {
            arguments = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(historyId, forKey: .historyId)
        try container.encodeIfPresent(hasTool, forKey: .hasTool)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(msg, forKey: .msg)
        try container.encodeIfPresent(arguments, forKey: .arguments)
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
