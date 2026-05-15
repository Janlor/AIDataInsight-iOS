// Generated from docs/cross-platform/contracts. Do not edit by hand.

export interface ApiEnvironment {
  name: string
  baseUrl: string
  description?: string | null
}

export const mockApiEnvironment: ApiEnvironment = {
  name: 'mock',
  baseUrl: "https://m1.apifoxmock.com/m1/3174267-1700689-default",
  description: 'iOS 当前学习项目使用的 Apifox mock host，各端默认开发环境必须与它保持一致。'
}

export interface AIChatEndpointContract {
  streamPath: string
}

export const aiChatEndpoint: AIChatEndpointContract = {
  streamPath: "/stream"
}

export interface AccountSession {
  accessToken?: string | null
  refreshToken?: string | null
  orgId?: number | null
  username?: string | null
  isLogin: boolean
}

export interface AccountUser {
  id?: number | null
  username?: string | null
  nickname?: string | null
  phone?: string | null
}

export enum AIHomeDestination {
  Chat = 'chat',
  History = 'history',
  Settings = 'settings'
}

export enum AIHomePanel {
  None = 'none',
  History = 'history'
}

export enum AIHomeCommand {
  OpenAIHome = 'openAIHome',
  OpenHistoryPanel = 'openHistoryPanel',
  CloseHistoryPanel = 'closeHistoryPanel',
  SelectHistoryConversation = 'selectHistoryConversation',
  StartNewConversation = 'startNewConversation',
  OpenSettings = 'openSettings',
  LogoutToLogin = 'logoutToLogin'
}

export interface AIHomeSession {
  isAuthenticated: boolean
  entryDestination: AIHomeDestination
  selectedHistoryId?: number | null
  activePanel: AIHomePanel
}

export enum HistoryDetailType {
  Question = '1',
  Answer = '2'
}

export enum HistoryContentType {
  Ai = '1',
  Chart = '2'
}

export interface HistoryDetail {
  id?: number | null
  historyId?: number | null
  type?: HistoryDetailType | null
  contentType?: HistoryContentType | null
  content?: string | null
  isLike?: string | null
  createTime?: string | null
  updateTime?: string | null
}

export interface HistoryRecord {
  id?: number | null
  name?: string | null
  createId?: number | null
  updateId?: number | null
  createName?: string | null
  updateName?: string | null
  createTime?: string | null
  updateTime?: string | null
  detailList?: Array<HistoryDetail> | null
}

export interface RecordPage {
  currentPage?: number | null
  pageSize?: number | null
  total?: number | null
  pages?: number | null
  cacheKey?: string | null
  records?: Array<HistoryRecord> | null
}

export interface TemplateQuestionSet {
  questions: Array<string>
}

export enum FunctionName {
  QueryArGroupByOrg = "queryArGroupByOrg",
  QueryArGroupByCustomer = "queryArGroupByCustomer",
  QuerySalesGroupByOrgAndGoodsType = "querySalesGroupByOrgAndGoodsType",
  QuerySalesGroupByMonth = "querySalesGroupByMonth",
  QuerySalesGroupByCustomer = "querySalesGroupByCustomer",
  QueryPurchaseGroupByOrg = "queryPurchaseGroupByOrg",
  QueryPurchaseGroupByMonth = "queryPurchaseGroupByMonth",
  QueryPurchaseGroupByCustomer = "queryPurchaseGroupByCustomer",
  QueryStockGroupByOrg = "queryStockGroupByOrg",
  QueryStockGroupByWarehouse = "queryStockGroupByWarehouse",
  QueryInventoryGroupByOrg = "queryInventoryGroupByOrg",
  QueryInventoryGroupByWarehouse = "queryInventoryGroupByWarehouse",
  QueryProcurementGroupByOrg = "queryProcurementGroupByOrg",
  QueryProcurementGroupByCustomer = "queryProcurementGroupByCustomer",
  QueryAccountAgeGroupByOrg = "queryAccountAgeGroupByOrg",
  QueryAccountAgeGroupByCustomer = "queryAccountAgeGroupByCustomer",
  QueryAccountGroupByAge = "queryAccountGroupByAge",
  QueryPerformanceType = "queryPerformanceType"
}

export enum FunctionArgumentKind {
  Basic = 'basic',
  TimeRange = 'timeRange',
  Warehouse = 'warehouse',
  AccountAge = 'accountAge',
  PerformanceType = 'performanceType'
}

    export function functionArgumentKindForName(name: FunctionName): FunctionArgumentKind {
      switch (name) {
    case FunctionName.QueryArGroupByOrg:
      return FunctionArgumentKind.Basic
    case FunctionName.QueryArGroupByCustomer:
      return FunctionArgumentKind.Basic
    case FunctionName.QuerySalesGroupByOrgAndGoodsType:
      return FunctionArgumentKind.TimeRange
    case FunctionName.QuerySalesGroupByMonth:
      return FunctionArgumentKind.TimeRange
    case FunctionName.QuerySalesGroupByCustomer:
      return FunctionArgumentKind.TimeRange
    case FunctionName.QueryPurchaseGroupByOrg:
      return FunctionArgumentKind.TimeRange
    case FunctionName.QueryPurchaseGroupByMonth:
      return FunctionArgumentKind.TimeRange
    case FunctionName.QueryPurchaseGroupByCustomer:
      return FunctionArgumentKind.TimeRange
    case FunctionName.QueryStockGroupByOrg:
      return FunctionArgumentKind.Warehouse
    case FunctionName.QueryStockGroupByWarehouse:
      return FunctionArgumentKind.Warehouse
    case FunctionName.QueryInventoryGroupByOrg:
      return FunctionArgumentKind.Warehouse
    case FunctionName.QueryInventoryGroupByWarehouse:
      return FunctionArgumentKind.Warehouse
    case FunctionName.QueryProcurementGroupByOrg:
      return FunctionArgumentKind.Warehouse
    case FunctionName.QueryProcurementGroupByCustomer:
      return FunctionArgumentKind.Warehouse
    case FunctionName.QueryAccountAgeGroupByOrg:
      return FunctionArgumentKind.AccountAge
    case FunctionName.QueryAccountAgeGroupByCustomer:
      return FunctionArgumentKind.AccountAge
    case FunctionName.QueryAccountGroupByAge:
      return FunctionArgumentKind.Basic
    case FunctionName.QueryPerformanceType:
      return FunctionArgumentKind.PerformanceType
        default:
          throw new Error('Unknown FunctionName: ' + name)
      }
    }

export interface BasicQuery {
  orgId?: number | null
  customerName?: string | null
  orderType?: string | null
  operator?: string | null
  value?: number | null
}

export interface TimeRangeQuery extends BasicQuery {
  startDate?: string | null
  endDate?: string | null
  goodsType?: number | null
}

export interface WarehouseQuery {
  orgId?: number | null
  warehouseName?: string | null
  goodsType?: number | null
  orderType?: string | null
  operator?: string | null
  value?: number | null
}

export interface AccountAgeQuery {
  orgId?: number | null
  customerName?: string | null
  orderType?: string | null
  valueArray?: Array<string> | null
}

export interface PerformanceTypeQuery {
  indexType?: string | null
}

export interface FunctionArguments {
  kind: FunctionArgumentKind
  basic?: BasicQuery | null
  timeRange?: TimeRangeQuery | null
  warehouse?: WarehouseQuery | null
  accountAge?: AccountAgeQuery | null
  performanceType?: PerformanceTypeQuery | null
}

export interface FunctionModel {
  historyId?: number | null
  hasTool?: boolean | null
  name?: FunctionName | null
  msg?: string | null
  arguments?: FunctionArguments | null
}

export interface ChartCommonItem {
  bizId?: string | null
  name?: string | null
  value?: number | null
}

export interface AccountAgeGroupItem {
  name?: string | null
  valueList?: Array<number> | null
  labelList?: Array<string> | null
  msg?: string | null
  chartType?: string | null
}

export interface HistoryChartDetail {
  funcType?: FunctionName | null
  chartCommonVoList?: Array<ChartCommonItem> | null
  accountAgeGroupVoList?: Array<AccountAgeGroupItem> | null
}

export enum ConversationRole {
  User = 'user',
  Assistant = 'assistant'
}

export enum ConversationContentKind {
  Welcome = 'welcome',
  Text = 'text',
  Intent = 'intent',
  Chart = 'chart'
}

export enum AIChatIntentType {
  Time = 'time',
  Index = 'index'
}

export enum FeedbackState {
  Liked = 'liked',
  Disliked = 'disliked',
  None = 'none',
  Unknown = 'unknown'
}

export enum ChartUnit {
  Currency = 'currency',
  Ton = 'ton'
}

export interface ChartSeries {
  xAxis: string
  labels: Array<string>
  values: Array<number>
}

export interface ChartPayload {
  functionName?: FunctionName | null
  unit: ChartUnit
  series: Array<ChartSeries>
  emptyMessage?: string | null
}

export interface ConversationMessage {
  id: string
  role: ConversationRole
  contentKind: ConversationContentKind
  text?: string | null
  intentType?: AIChatIntentType | null
  chartPayload?: ChartPayload | null
  feedback: FeedbackState
  historyDetailId?: number | null
  functionName?: FunctionName | null
}
