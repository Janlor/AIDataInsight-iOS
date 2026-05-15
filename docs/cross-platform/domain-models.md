# AIDataInsight Domain Models

## 文档目的

这份文档定义 AIDataInsight 当前跨端应该共享的领域模型母版。

> 机器可读源事实位于 `docs/cross-platform/contracts/domain/`。
> 本文档用于解释模型语义、命名取舍和 iOS 遗留映射；新增或变更跨端模型时，必须先更新对应 JSON Schema。

它服务于四件事：

- 固定跨端的业务对象命名
- 固定核心字段语义
- 防止 iOS / Android / Web / Desktop 各自长出不同模型
- 作为 AI 生成多端代码时的主要输入之一

这份文档只描述：

- domain entity
- value object
- enum / discriminated union
- use case output 的领域语义

它不描述：

- UIKit / Compose / React 的 UI model
- DTO 细节
- 页面 view data
- 平台专属路由对象

---

## 1. 总体原则

### 1.1 先有 Domain，再有 UI State

顺序必须是：

1. 先定义 domain model
2. 再定义 use case output
3. 再定义各端 UI state / view data

### 1.2 Canonical Name Only

跨端母版只保留规范命名，不传播历史拼写或平台遗留字段名。

例如：

- iOS 当前 `UserInfo` 里有 `nikeName`
- 跨端 canonical name 应定义为 `nickname`

各端可以在 mapper 层做兼容，但不能把遗留命名继续扩散为跨端母版。

### 1.3 可空字段不等于可省略语义

如果当前 iOS 模型使用了很多可选值，跨端实现时应区分：

- `nullable because backend really allows missing`
- `nullable because current iOS model is still宽松`

默认不凭空收紧，但应在文档中明确语义。

---

## 2. Account Domain

### 2.1 AccountSession

来源：

- `Packages/library-basics/Sources/AccountProtocol/AccountInfo.swift`
- `Packages/library-basics/Sources/AccountProtocol/AccountProtocol.swift`

Canonical Model:

```text
AccountSession
  accessToken: String?
  refreshToken: String?
  orgId: Int?
  username: String?
  isLogin: Bool
```

说明：

- `accessToken` 和 `refreshToken` 是最基础的会话字段
- `orgId` 与 `username` 当前属于 session store 对外语义的一部分
- `isLogin` 是派生状态，不一定需要后端直接返回

跨端要求：

- 四端都必须提供等价 session 读取能力
- `isLogin` 应由 session 内容推导，而不是单独长期持久化为真值
- 登录接口返回后，必须先把接口字段归一化为 `AccountSession`，再写入 session store
- 自动登录必须在应用启动时读取已持久化 session，并通过 route intent 决定进入 Login 或 AI Home
- 退出登录、401 会话失效、402 刷新失败时必须清除持久化 session，再回到 Login

字段归一化规则：

- 领域层统一使用 `accessToken` / `refreshToken` / `orgId`
- 接口层需要兼容 mock 或后端返回的 `access_token` / `refresh_token` / `org_id`
- snake_case 只能停留在 API DTO / remote service 归一化边界内，不能泄漏到 Repository、UseCase 或 UI

自动登录规则：

1. 启动阶段先读取本地 session store。
2. `accessToken` 非空时，`isLogin = true`，输出 `openAIHome`。
3. `accessToken` 为空时，`isLogin = false`，输出 `openLogin`。
4. 登录成功后必须先持久化归一化后的 token，再替换主页面为 AI Home。
5. 退出登录必须先清除 token，再替换主页面为 Login。

### 2.2 AccountUser

来源：

- `Packages/library-basics/Sources/AccountProtocol/UserInfo.swift`
- `Packages/library-common/Sources/Setting/Domain/Models/SettingAccountInfo.swift`

Canonical Model:

```text
AccountUser
  id: Int?
  username: String?
  nickname: String?
  phone: String?
```

命名规则：

- canonical name 使用 `nickname`
- iOS 当前 `nikeName` 只视为 legacy source field

跨端要求：

- Android / Web / Desktop 不继续使用 `nikeName`
- iOS 后续如果重构字段命名，应向 `nickname` 靠拢

### 2.3 MenuItem

来源：

- `Packages/library-basics/Sources/AccountProtocol/MenuProtocol.swift`

Canonical Model:

```text
MenuItem
  id: MenuId?
  name: String?
```

### 2.4 MenuId

来源：

- `Packages/library-basics/Sources/AccountProtocol/MenuProtocol.swift`

Canonical Enum:

```text
MenuId
  group = 9002
  company = 9003
  approval = 9004
  message = 9005
```

### 2.5 UserOrg

来源：

- `Packages/library-basics/Sources/AccountProtocol/UserOrgProtocal.swift`

Canonical Model:

```text
UserOrg
  id: Int?
  name: String?
```

---

## 3. Setting Domain

### 3.1 SettingAccountInfo

来源：

- `Packages/library-common/Sources/Setting/Domain/Models/SettingAccountInfo.swift`

Canonical Model:

```text
SettingAccountInfo
  nickname: String?
  username: String?
  phone: String?
```

### 3.2 SettingCapability

来源：

- `Packages/library-common/Sources/Setting/Domain/Models/SettingCapability.swift`

Canonical Model:

```text
SettingCapability
  canUpdatePassword: Bool
  canOpenPrivacy: Bool
  canLogout: Bool
```

### 3.3 SettingSnapshot

来源：

- `Packages/library-common/Sources/Setting/Domain/Models/SettingSnapshot.swift`

Canonical Model:

```text
SettingSnapshot
  accountInfo: SettingAccountInfo
  capability: SettingCapability
  appVersion: String
```

规则：

- `SettingSnapshot` 是跨端共享的核心聚合对象
- 各端 UI 先消费 snapshot，再映射为本端 `UiState` / `ViewData`

### 3.4 SettingItemAction

来源：

- `Packages/library-common/Sources/Setting/Domain/Models/SettingItemAction.swift`

Canonical Enum:

```text
SettingItemAction
  updatePassword
  privacy
  logout
```

说明：

- 这是设置页语义动作
- 不等于某端路由 API

### 3.5 Setting 页面语义

来源：

- `Packages/library-common/Sources/Setting/SettingViewController.swift`
- `Packages/library-common/Sources/Setting/Presentation/ViewModels/SettingViewModel.swift`
- `app-android/feature/setting/src/main/java/com/aidatainsight/android/feature/setting/ui/SettingScreen.kt`

跨端页面结构：

```text
Setting
  title: 设置
  sections:
    account:
      - 昵称
      - 登录名
      - 手机号
    about:
      - 隐私政策
      - App版本
    logout:
      - 退出登录
```

跨端要求：

- Setting 是已登录后的受保护页面，未登录时不能渲染账户信息
- 页面采用分组列表语义，不是营销页或 dashboard
- 空的昵称、登录名、手机号统一显示 `未设置`
- `隐私政策` 行可点击并显示 disclosure，触发 `openPrivacy`
- `App版本` 行只展示文本，不可点击
- `退出登录` 行单独成组，红色、居中、点击前必须弹出确认
- 退出确认文案固定为 `确认注销并退出系统吗？`，按钮为 `取消` / `确定`
- 退出成功后清理 session，并替换 root/main surface 到 Login
- iOS 可以用 SF Symbols 作为装饰图标；Android / Web 只有存在明确匹配的系统或图标库图标时才显示
- 如果目标端没有合适图标，直接省略图标，不能用 `人`、`盾`、`i` 等文字假装图标

---

## 4. Environment Domain

### 4.1 ApiEnvironment

来源：

- `Packages/library-basics/Sources/Environment/AppEnvironmentValues.swift`
- `docs/cross-platform/contracts/domain/environment.schema.json`

Canonical Model:

```text
ApiEnvironment
  name: mock | dev | sit | uat | staging | pre | production
  baseUrl: String
  description: String?
```

### 4.2 MockApiEnvironment

当前学习项目默认使用 iOS 已验证的 Apifox mock host：

```text
https://m1.apifoxmock.com/m1/3174267-1700689-default
```

跨端要求：

- iOS / Android / Web 在没有显式环境覆盖时，都应默认使用这个 mock host。
- 真实后端环境可以通过平台环境配置覆盖，但不能把 `example.invalid` 当作可运行默认值。
- API path / method / response envelope 仍以 `contracts/api/openapi.yaml` 为准。

---

## 5. History Domain

### 5.1 RecordPage

来源：

- `Packages/module-ai/Sources/ModuleAI/Domain/History/HistoryModel.swift`

Canonical Model:

```text
RecordPage
  currentPage: Int?
  pageSize: Int?
  total: Int?
  pages: Int?
  cacheKey: String?
  records: [HistoryRecord]?
```

说明：

- 当前 iOS 名称是 `RecordPageModel`
- 跨端母版统一称为 `RecordPage`

### 5.2 HistoryRecord

来源：

- `Packages/module-ai/Sources/ModuleAI/Domain/History/HistoryModel.swift`

Canonical Model:

```text
HistoryRecord
  id: Int?
  name: String?
  createId: Int?
  updateId: Int?
  createName: String?
  updateName: String?
  createTime: String?
  updateTime: String?
  detailList: [HistoryDetail]?
```

### 5.3 HistoryDetail

来源：

- `Packages/module-ai/Sources/ModuleAI/Domain/History/HistoryModel.swift`

Canonical Model:

```text
HistoryDetail
  id: Int?
  historyId: Int?
  type: HistoryDetailType?
  contentType: HistoryContentType?
  content: String?
  isLike: String?
  createTime: String?
  updateTime: String?
```

说明：

- 当前 `isLike` 仍是字符串语义
- 在后端契约未稳定前，不要擅自改成 `Bool`

### 5.4 HistoryDetailType

来源：

- `Packages/module-ai/Sources/ModuleAI/Domain/History/HistoryModel.swift`

Canonical Enum:

```text
HistoryDetailType
  question = "1"
  answer = "2"
```

### 5.5 HistoryContentType

来源：

- `Packages/module-ai/Sources/ModuleAI/Domain/History/HistoryModel.swift`

Canonical Enum:

```text
HistoryContentType
  ai = "1"
  chart = "2"
```

### 5.6 History 页面语义

来源：

- `Packages/module-ai/Sources/ModuleAI/Presentation/History/ViewControllers/HistoryViewController.swift`
- `Packages/module-ai/Sources/ModuleAI/Presentation/History/ViewData/HistoryListViewData.swift`
- `app-android/feature/history/src/main/java/com/aidatainsight/android/feature/history/ui/HistoryScreen.kt`

跨端页面结构：

```text
History
  title: 历史会话
  sections:
    today: 今天
    thisMonth: 本月
    other: 其它
```

跨端要求：

- History 是 AI Home 的历史辅助面板/页面，不是独立替换 Chat 的新根页面。
- 选择历史会话后，必须让现有 AI Chat 加载该 `historyId`。
- 行内容展示会话名称和时间；今天显示 `HH:mm`，本月显示 `MM-dd`，其它显示 `yyyy-MM-dd`。
- 当前参考 UI 顶部只保留设置入口；刷新和清空全部不能作为常驻主按钮展示。
- 单条删除通过长按或 secondary action 暴露 `删除` 菜单，不能默认在每行放行内删除按钮。
- 有数据时刷新必须无感，不能用整屏 loading 覆盖已有列表。

---

## 6. AI Chat Domain

### 6.0 AIChatEndpoint

来源：

- `Packages/module-ai/Sources/ModuleAI/Domain/AIChat/AIChatEndpoint.swift`
- `docs/cross-platform/contracts/domain/ai-chat.schema.json`

Canonical Model:

```text
AIChatEndpoint
  streamPath: "/stream"
```

说明：

- `streamPath` 属于 AI Chat 子域，不属于全局环境配置。
- AI Chat SSE URL 由平台网络层使用 `baseUrl + AIChatEndpoint.streamPath` 组合得到。
- Repository 只能调用端侧 API descriptor / remote service，不能硬编码完整 URL。

### 6.1 TemplateQuestionSet

来源：

- `Packages/module-ai/Sources/ModuleAI/Domain/AIChat/TemplateModel.swift`

Canonical Model:

```text
TemplateQuestionSet
  questions: [String]
```

说明：

- 当前 iOS 名称为 `TemplateModel`
- 跨端母版更强调语义，可命名为 `TemplateQuestionSet`
- `TemplateQuestionSet` 是应用层和 UI state 看到的唯一形态。
- 如果接口外壳 `data` 返回的是内嵌 JSON 字符串，端侧网络层或 AI Chat remote service 必须先解码字符串，再映射为 `TemplateQuestionSet`。
- Repository / UseCase / Presentation 不应把 `String data` 继续向上传递，也不应让 UI 直接解析接口字符串。

### 6.1.1 AIChat 页面语义

来源：

- `Packages/module-ai/Sources/ModuleAI/Presentation/AIChat/ViewControllers/AIChatViewController.swift`
- `Packages/module-ai/Sources/ModuleAI/Presentation/AIChat/Views/AIChatBottomView.swift`
- `app-android/feature/ai-chat/src/main/java/com/aidatainsight/android/feature/aichat/ui/AIChatScreen.kt`

跨端页面结构：

```text
AIChat
  background: background_vc
  welcome:
    intro: AI 助手介绍
    questions: TemplateQuestionSet.questions
    example: 时间范围 / 指标名称 / 过滤条件 / 分组维度
  messages:
    user: right aligned gradient bubble
    assistant: left aligned grouped bubble
  composer:
    placeholder: 请输入您的数据分析查询。
```

跨端要求：

- AIChat 是 AI Home 的主内容；嵌入 AI Home 时，标题、历史入口和新会话入口由 AI Home shell 管理。
- 模板问题必须显示在 AI 欢迎气泡内，不能生成普通推荐卡片或营销区块。
- 点击推荐问题等价于发送该问题，不能只填充输入框后等待用户再次点击发送。
- 用户消息靠右，AI 消息靠左；图表结果仍按 AI 消息承载，并使用固定 fallback 文案兜底。
- 图表 UI 只能消费 `ChartPayload`：普通图表显示为柱状图，账龄等多值图表显示为堆叠柱状图，单位按“万”展示。
- 图表生成后，聊天 transcript 必须滚动到底部锚点，确保图表和反馈区可见。
- 反馈只属于有 `historyDetailId` 的 chart message；点赞/点踩请求值必须保持字符串 `"1"` / `"0"` 语义，失败后回滚选择态。
- `UIImage.imageNamed` 代表可跨端同步的项目资产；`UIImage(systemName:)` / SF Symbols 代表 iOS 平台装饰。
- 输入区是底部胶囊 composer，思考或流式返回期间禁用发送。
- iOS 的背景图、图片按钮和 SF Symbols 是平台实现；跨端源事实是背景语义、消息布局、欢迎内容、输入行为和错误兜底。

### 6.2 FunctionModel

来源：

- `Packages/module-ai/Sources/ModuleAI/Domain/AIChat/FunctionModel.swift`

Canonical Model:

```text
FunctionModel
  historyId: Int?
  hasTool: Bool?
  name: FunctionName?
  msg: String?
  arguments: FunctionArguments?
```

### 6.3 FunctionName

来源：

- `Packages/module-ai/Sources/ModuleAI/Domain/AIChat/FunctionName.swift`

Canonical Enum Values:

```text
queryArGroupByOrg
queryArGroupByCustomer
querySalesGroupByOrgAndGoodsType
querySalesGroupByMonth
querySalesGroupByCustomer
queryPurchaseGroupByOrg
queryPurchaseGroupByMonth
queryPurchaseGroupByCustomer
queryStockGroupByOrg
queryStockGroupByWarehouse
queryInventoryGroupByOrg
queryInventoryGroupByWarehouse
queryProcurementGroupByOrg
queryProcurementGroupByCustomer
queryAccountAgeGroupByOrg
queryAccountAgeGroupByCustomer
queryAccountGroupByAge
queryPerformanceType
```

规则：

- `FunctionName.rawValue` 是跨端稳定契约
- 不允许某一端私自重命名

### 6.4 FunctionArguments

来源：

- `Packages/module-ai/Sources/ModuleAI/Domain/AIChat/FunctionArguments.swift`
- `Packages/module-ai/Sources/ModuleAI/Domain/AIChat/FunctionQueryModels.swift`

Canonical Union:

```text
FunctionArguments
  basic(BasicQuery)
  timeRange(TimeRangeQuery)
  warehouse(WarehouseQuery)
  accountAge(AccountAgeQuery)
  performanceType(PerformanceTypeQuery)
```

### 6.5 BasicQuery

Canonical Model:

```text
BasicQuery
  orgId: Int?
  customerName: String?
  orderType: String?
  operator: String?
  value: Double?
```

### 6.6 TimeRangeQuery

Canonical Model:

```text
TimeRangeQuery
  startDate: String?
  endDate: String?
  orgId: Int?
  customerName: String?
  goodsType: Int?
  orderType: String?
  operator: String?
  value: Double?
```

### 6.7 WarehouseQuery

Canonical Model:

```text
WarehouseQuery
  orgId: Int?
  warehouseName: String?
  goodsType: Int?
  orderType: String?
  operator: String?
  value: Double?
```

### 6.8 AccountAgeQuery

Canonical Model:

```text
AccountAgeQuery
  orgId: Int?
  customerName: String?
  orderType: String?
  valueArray: [String]?
```

### 6.9 PerformanceTypeQuery

Canonical Model:

```text
PerformanceTypeQuery
  indexType: String?
```

### 6.10 HistoryChartDetail

来源：

- `Packages/module-ai/Sources/ModuleAI/Domain/AIChat/HistoryDetailModel.swift`

Canonical Model:

```text
HistoryChartDetail
  funcType: FunctionName?
  chartCommonVoList: [ChartCommonItem]?
  accountAgeGroupVoList: [AccountAgeGroupItem]?
```

### 6.11 ChartCommonItem

Canonical Model:

```text
ChartCommonItem
  bizId: String?
  name: String?
  value: Double?
```

### 6.12 AccountAgeGroupItem

Canonical Model:

```text
AccountAgeGroupItem
  name: String?
  valueList: [Double]?
  labelList: [String]?
  msg: String?
  chartType: String?
```

说明：

- `chartType` 当前仍是字符串语义
- 在接口稳定前不强行提升为 enum

---

## 7. Application Output Models

这些对象不是最底层 domain entity，但属于跨端共享的 use case 语义。

### 7.1 UseCaseFailure

来源：

- `Packages/module-ai/Sources/ModuleAI/Application/Models/UseCaseModels.swift`

Canonical Model:

```text
UseCaseFailure
  message: String?
```

### 7.2 LoadTemplateOutput

Canonical Model:

```text
LoadTemplateOutput
  questions: [String]
```

### 7.3 SendFunctionMessageOutput

Canonical Union:

```text
SendFunctionMessageOutput
  intent(text: String, type: AIChatIntentType)
  chartRequest(name: FunctionName, historyId: Int, arguments: FunctionArguments)
```

说明：

- 这是典型的跨端共享业务分支
- Android / Web 不要把这块重新写成完全不同的结果结构

---

## 8. Naming Rules

### 8.1 Canonical Names

跨端新增实现时优先使用以下名字：

- `AccountSession`
- `AccountUser`
- `MenuItem`
- `UserOrg`
- `SettingSnapshot`
- `HistoryRecord`
- `HistoryDetail`
- `FunctionModel`
- `FunctionArguments`
- `FunctionName`

### 8.2 Legacy Names

以下名称视为 iOS 当前实现遗留，不应继续扩散：

- `nikeName`
- `UserOrgProtocal`
- `RecordPageModel`
- `RecordModel`
- `DetailModel`
- `TemplateModel`

说明：

- 这些名字暂时不要求立刻在 iOS 内部重构
- 但 Android / Web / Desktop 的新实现应以 canonical name 为准

---

## 9. 同步规则

当这些模型发生变化时：

1. 先更新本文件
2. 再更新 `Docs/architecture/*` 映射文档
3. 再更新 iOS 当前实现
4. 再同步 Android / Web / Desktop
5. 最后在 `Docs/cross-platform/change-log.md` 追加记录

---

## 10. 当前缺口

这份初稿还没有展开这些对象：

- 统一错误模型
- AIChat message view-independent model
- History grouping model
- Privacy agreement domain model
- Login request / response canonical model

这些建议作为下一轮补齐。

---

## 一句话结论

四端真正应该共享的不是“页面代码”，而是这份领域模型母版里的对象、字段语义和命名规则。
