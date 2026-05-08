import Testing
@testable import ModuleAI

struct FunctionArgumentSchemaTests {
    @Test
    func allFunctionNames_haveKnownArgumentKind() {
        #expect(FunctionName.allCases.count == 18)
        #expect(FunctionName.allCases.allSatisfy { $0.argumentKind != nil })
    }
    
    @Test
    func argumentKind_matchesCanonicalGroups() {
        #expect(FunctionName.queryArGroupByOrg.argumentKind == .basic)
        #expect(FunctionName.queryArGroupByCustomer.argumentKind == .basic)
        #expect(FunctionName.queryAccountGroupByAge.argumentKind == .basic)
        
        #expect(FunctionName.querySalesGroupByOrgAndGoodsType.argumentKind == .timeRange)
        #expect(FunctionName.querySalesGroupByMonth.argumentKind == .timeRange)
        #expect(FunctionName.querySalesGroupByCustomer.argumentKind == .timeRange)
        #expect(FunctionName.queryPurchaseGroupByOrg.argumentKind == .timeRange)
        #expect(FunctionName.queryPurchaseGroupByMonth.argumentKind == .timeRange)
        #expect(FunctionName.queryPurchaseGroupByCustomer.argumentKind == .timeRange)
        
        #expect(FunctionName.queryStockGroupByOrg.argumentKind == .warehouse)
        #expect(FunctionName.queryStockGroupByWarehouse.argumentKind == .warehouse)
        #expect(FunctionName.queryInventoryGroupByOrg.argumentKind == .warehouse)
        #expect(FunctionName.queryInventoryGroupByWarehouse.argumentKind == .warehouse)
        #expect(FunctionName.queryProcurementGroupByOrg.argumentKind == .warehouse)
        #expect(FunctionName.queryProcurementGroupByCustomer.argumentKind == .warehouse)
        
        #expect(FunctionName.queryAccountAgeGroupByOrg.argumentKind == .accountAge)
        #expect(FunctionName.queryAccountAgeGroupByCustomer.argumentKind == .accountAge)
        
        #expect(FunctionName.queryPerformanceType.argumentKind == .performanceType)
    }
}

