// Generated from docs/cross-platform/contracts. Do not edit by hand.

export const mockApiEnvironment = {
  name: 'mock',
  baseUrl: "https://m1.apifoxmock.com/m1/3174267-1700689-default",
  description: 'iOS 当前学习项目使用的 Apifox mock host，各端默认开发环境必须与它保持一致。',
} as const;

export const aiChatEndpoint = {
  streamPath: "/stream",
} as const;

export interface ApiEnvironment {
  name: 'mock' | 'dev' | 'sit' | 'uat' | 'staging' | 'pre' | 'production';
  baseUrl: string;
  description?: string | null;
}

export interface AccountSession {
  accessToken?: string | null;
  refreshToken?: string | null;
  orgId?: number | null;
  username?: string | null;
  isLogin: boolean;
}

export interface AccountUser {
  id?: number | null;
  username?: string | null;
  nickname?: string | null;
  phone?: string | null;
}

export type SettingRowAction = 'none' | 'openPrivacy' | 'confirmLogout' | 'openUpdatePassword';

export interface SettingRow {
  kind: 'nickname' | 'username' | 'phone' | 'privacy' | 'appVersion' | 'logout';
  title: string;
  detail: string | null;
  action: SettingRowAction;
  selectable: boolean;
  destructive: boolean;
  centered: boolean;
  showsDisclosure: boolean;
}

export interface SettingSection {
  kind: 'account' | 'about' | 'logout';
  title: string | null;
  rows: SettingRow[];
}

export interface SettingLogoutDialogState {
  visible: boolean;
  title: string;
  cancelTitle: string;
  confirmTitle: string;
  confirmRole: 'destructive';
}

export interface SettingUiState {
  title: string;
  isLoading: boolean;
  isLoggingOut: boolean;
  errorMessage: string | null;
  sections: SettingSection[];
  logoutDialog: SettingLogoutDialogState;
}

export const settingInitialUiState: SettingUiState = {
      "title": "设置",
      "isLoading": false,
      "isLoggingOut": false,
      "errorMessage": null,
      "sections": [
        {
          "kind": "account",
          "title": "账户",
          "rows": [
            {
              "kind": "nickname",
              "title": "昵称",
              "detail": "未设置",
              "action": "none",
              "selectable": false,
              "destructive": false,
              "centered": false,
              "showsDisclosure": false
            },
            {
              "kind": "username",
              "title": "登录名",
              "detail": "demo",
              "action": "none",
              "selectable": false,
              "destructive": false,
              "centered": false,
              "showsDisclosure": false
            },
            {
              "kind": "phone",
              "title": "手机号",
              "detail": "未设置",
              "action": "none",
              "selectable": false,
              "destructive": false,
              "centered": false,
              "showsDisclosure": false
            }
          ]
        },
        {
          "kind": "about",
          "title": "关于",
          "rows": [
            {
              "kind": "privacy",
              "title": "隐私政策",
              "detail": null,
              "action": "openPrivacy",
              "selectable": true,
              "destructive": false,
              "centered": false,
              "showsDisclosure": true
            },
            {
              "kind": "appVersion",
              "title": "App版本",
              "detail": "0.1.0 (1)",
              "action": "none",
              "selectable": false,
              "destructive": false,
              "centered": false,
              "showsDisclosure": false
            }
          ]
        },
        {
          "kind": "logout",
          "title": null,
          "rows": [
            {
              "kind": "logout",
              "title": "退出登录",
              "detail": null,
              "action": "confirmLogout",
              "selectable": true,
              "destructive": true,
              "centered": true,
              "showsDisclosure": false
            }
          ]
        }
      ],
      "logoutDialog": {
        "visible": false,
        "title": "确认注销并退出系统吗？",
        "cancelTitle": "取消",
        "confirmTitle": "确定",
        "confirmRole": "destructive"
      }
    };

export type AIHomeDestination = 'chat' | 'history' | 'settings';
export type AIHomePanel = 'none' | 'history';
export type AIHomeCommand =
  | 'openAIHome'
  | 'openHistoryPanel'
  | 'closeHistoryPanel'
  | 'selectHistoryConversation'
  | 'startNewConversation'
  | 'openSettings'
  | 'logoutToLogin';

export interface AIHomeSession {
  isAuthenticated: boolean;
  entryDestination: AIHomeDestination;
  selectedHistoryId?: number | null;
  activePanel: AIHomePanel;
}

export interface HistoryDetail {
  id?: number | null;
  historyId?: number | null;
  type?: '1' | '2' | null;
  contentType?: '1' | '2' | null;
  content?: string | null;
  isLike?: '1' | '0' | null;
  createTime?: string | null;
  updateTime?: string | null;
}

export interface HistoryRecord {
  id?: number | null;
  name?: string | null;
  createId?: number | null;
  updateId?: number | null;
  createName?: string | null;
  updateName?: string | null;
  createTime?: string | null;
  updateTime?: string | null;
  detailList?: HistoryDetail[] | null;
}

export interface RecordPage {
  currentPage?: number | null;
  pageSize?: number | null;
  total?: number | null;
  pages?: number | null;
  cacheKey?: string | null;
  records?: HistoryRecord[] | null;
}

export interface TemplateQuestionSet {
  questions: string[];
}

export type FunctionName =
  | 'queryArGroupByOrg'
  | 'queryArGroupByCustomer'
  | 'querySalesGroupByOrgAndGoodsType'
  | 'querySalesGroupByMonth'
  | 'querySalesGroupByCustomer'
  | 'queryPurchaseGroupByOrg'
  | 'queryPurchaseGroupByMonth'
  | 'queryPurchaseGroupByCustomer'
  | 'queryStockGroupByOrg'
  | 'queryStockGroupByWarehouse'
  | 'queryInventoryGroupByOrg'
  | 'queryInventoryGroupByWarehouse'
  | 'queryProcurementGroupByOrg'
  | 'queryProcurementGroupByCustomer'
  | 'queryAccountAgeGroupByOrg'
  | 'queryAccountAgeGroupByCustomer'
  | 'queryAccountGroupByAge'
  | 'queryPerformanceType';

export type FunctionArgumentKind = 'basic' | 'timeRange' | 'warehouse' | 'accountAge' | 'performanceType';

export const functionArgumentKindByName: Record<FunctionName, FunctionArgumentKind> = {
  "queryArGroupByOrg": 'basic',
  "queryArGroupByCustomer": 'basic',
  "queryAccountGroupByAge": 'basic',
  "querySalesGroupByOrgAndGoodsType": 'timeRange',
  "querySalesGroupByMonth": 'timeRange',
  "querySalesGroupByCustomer": 'timeRange',
  "queryPurchaseGroupByOrg": 'timeRange',
  "queryPurchaseGroupByMonth": 'timeRange',
  "queryPurchaseGroupByCustomer": 'timeRange',
  "queryStockGroupByOrg": 'warehouse',
  "queryStockGroupByWarehouse": 'warehouse',
  "queryInventoryGroupByOrg": 'warehouse',
  "queryInventoryGroupByWarehouse": 'warehouse',
  "queryProcurementGroupByOrg": 'warehouse',
  "queryProcurementGroupByCustomer": 'warehouse',
  "queryAccountAgeGroupByOrg": 'accountAge',
  "queryAccountAgeGroupByCustomer": 'accountAge',
  "queryPerformanceType": 'performanceType'
};

export interface BasicQuery {
  orgId?: number | null;
  customerName?: string | null;
  orderType?: string | null;
  operator?: string | null;
  value?: number | null;
}

export interface TimeRangeQuery extends BasicQuery {
  startDate?: string | null;
  endDate?: string | null;
  goodsType?: number | null;
}

export interface WarehouseQuery {
  orgId?: number | null;
  warehouseName?: string | null;
  goodsType?: number | null;
  orderType?: string | null;
  operator?: string | null;
  value?: number | null;
}

export interface AccountAgeQuery {
  orgId?: number | null;
  customerName?: string | null;
  orderType?: string | null;
  valueArray?: string[] | null;
}

export interface PerformanceTypeQuery {
  indexType?: string | null;
}

export type FunctionArguments =
  | { kind: 'basic'; value: BasicQuery }
  | { kind: 'timeRange'; value: TimeRangeQuery }
  | { kind: 'warehouse'; value: WarehouseQuery }
  | { kind: 'accountAge'; value: AccountAgeQuery }
  | { kind: 'performanceType'; value: PerformanceTypeQuery };

export interface FunctionModel {
  historyId?: number | null;
  hasTool?: boolean | null;
  name?: FunctionName | null;
  msg?: string | null;
  arguments?: FunctionArguments | null;
}

export interface ChartCommonItem {
  bizId?: string | null;
  name?: string | null;
  value?: number | null;
}

export interface AccountAgeGroupItem {
  name?: string | null;
  valueList?: number[] | null;
  labelList?: string[] | null;
  msg?: string | null;
  chartType?: string | null;
}

export interface HistoryChartDetail {
  historyDetailId?: number | null;
  funcType?: FunctionName | null;
  chartCommonVoList?: ChartCommonItem[] | null;
  accountAgeGroupVoList?: AccountAgeGroupItem[] | null;
}

export type ConversationRole = 'user' | 'assistant';
export type ConversationContentKind = 'welcome' | 'text' | 'intent' | 'chart';
export type AIChatIntentType = 'time' | 'index';
export type FeedbackState = 'liked' | 'disliked' | 'none' | 'unknown';
export type ChartUnit = 'currency' | 'ton';

export interface ChartSeries {
  xAxis: string;
  labels: string[];
  values: number[];
}

export interface ChartPayload {
  functionName?: FunctionName | null;
  unit: ChartUnit;
  series: ChartSeries[];
  emptyMessage?: string | null;
}

export interface ConversationMessage {
  id: string;
  role: ConversationRole;
  contentKind: ConversationContentKind;
  text?: string | null;
  intentType?: AIChatIntentType | null;
  chartPayload?: ChartPayload | null;
  feedback: FeedbackState;
  historyDetailId?: number | null;
  functionName?: FunctionName | null;
}
