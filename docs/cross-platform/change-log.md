# Cross-Platform Change Flow

## 文档目的

这份文档不只是记录“改了什么”。

它更重要的作用是固定一条流程：

- 任何一端发生修改时
- 先判断这次修改属于哪一类
- 再决定要同步到哪些端
- 最后决定更新顺序

这份文档服务于当前目标：

- 设计一套稳定领域模型
- 让 AI 稳定地产生 iOS / Android / HarmonyOS NEXT / Web，并为其它候选端保留扩展空间

---

## 1. 核心原则

### 1.1 不追求各端代码相同

四端保持一致的，不是代码，而是：

- 领域模型
- API 契约
- 设计 token
- 关键交互规则
- 模块边界与命名

### 1.2 平台实现允许不同

以下内容不要求代码同步：

- UIKit / Compose / ArkUI / React / Desktop UI 代码
- 动画 API
- 布局系统
- 路由实现
- 各平台资源文件格式

### 1.3 先更新母版，再更新各端

如果变更影响跨端源事实，顺序必须是：

1. 先从 iOS 真实实现提炼契约草案
2. 再更新 `docs/cross-platform/contracts/` 中的机器可读契约
3. 再更新跨端解释文档和必要 fixtures
4. 再按契约生成或调整 Android
5. 再用 Android 运行验证契约
6. 如果 Android 暴露跨端问题，回写契约和 fixtures，再修正 Android
7. 再让 HarmonyOS NEXT / Web / 后续端从已验证契约生成
8. 最后记录本次变更影响范围

固定节奏：

```text
iOS reference -> contract draft -> Android validation -> contract refinement -> HarmonyOS native generation -> Web generation
```

Android 验证后回写契约不是返工，而是契约从草案变成已验证源事实的必要步骤。

机器可读契约包括：

- `contracts/domain/*.schema.json`
- `contracts/api/openapi.yaml`
- `contracts/usecases/*.usecases.yaml`
- `contracts/ui-state/*.yaml`
- `contracts/ui-layout/*.yaml`
- `contracts/routes/route-intents.yaml`
- `contracts/design/tokens.json`
- `contracts/fixtures/**/*`

旧流程中的“母版文档”现在拆成两层：

- `contracts/` 是多端生成和测试的源事实
- Markdown 文档是语义说明和决策背景

历史顺序曾经是：

1. 先更新跨端母版文档
2. 再更新当前端实现
3. 再同步到其它端
4. 最后记录本次变更影响范围

---

## 2026-05-15 - Platform Priority Update

### Context

iOS 和 Android 已完成主要功能开发。下一阶段端侧适配优先级从“Android 后优先 Web，HarmonyOS NEXT 作为候选端”调整为：

1. iOS
2. Android
3. HarmonyOS NEXT
4. Web
5. macOS / Windows 等其它候选端

### Rule

- Android 继续作为已验证端和契约回归端。
- HarmonyOS NEXT 成为 Android 后的下一优先级，按 ArkTS / ArkUI / DevEco Studio 原生路线生成。
- Web 仍保留已有 TypeScript contract models，但完整 Web 工程排在 HarmonyOS NEXT 主链路之后。
- HarmonyOS NEXT 和 Web 都只能从修正后的契约生成，不能从 iOS 或 Android 页面反推。

---

## 2. 变更分类

任何改动先归类，不能直接开始“翻译到其它端”。

### 2.1 Domain Change

定义：

- 领域模型变化
- 业务规则变化
- 用例边界变化

常见例子：

- `SettingSnapshot` 新增字段
- 历史记录分组规则变化
- AI 意图识别规则变化

同步要求：

- 必须同步到四端

需要更新：

- `docs/cross-platform/contracts/domain/*.schema.json`
- `docs/cross-platform/domain-models.md`
- `Docs/architecture/*` 中相关映射文档
- 各端 domain / usecase / viewmodel

### 2.2 API Contract Change

定义：

- 接口路径
- 请求参数
- 响应结构
- 错误码
- token refresh / session 规则

同步要求：

- 必须同步到四端

需要更新：

- `docs/cross-platform/contracts/api/openapi.yaml`
- `docs/cross-platform/api-contract.md`
- 各端 network / repository / dto / mapper

### 2.3 Design Token Change

定义：

- 颜色
- 字体层级
- 间距规则
- 图表色板
- 图标语义
- 背景语义

常见例子：

- 品牌主色从绿色改为蓝色
- `tertiery` 修正为 `tertiary`
- App icon 风格变化

同步要求：

- 原则上同步到四端

需要更新：

- `docs/cross-platform/contracts/design/tokens.json`
- `docs/cross-platform/design-tokens.md`
- iOS / Android / HarmonyOS NEXT / Web / 其它候选端 theme token 映射

### 2.4 Interaction Rule Change

定义：

- 同一业务在各端应该保持一致的交互规则

常见例子：

- 登录成功后如何切主区
- 隐私协议何时弹出
- 历史删除后的刷新策略

同步要求：

- 必须同步到四端

需要更新：

- `docs/cross-platform/contracts/usecases/*.usecases.yaml`
- `docs/cross-platform/contracts/ui-state/*.yaml`
- `Docs/cross-platform/interaction-rules.md`
- 各端 coordinator / route / state / event handling

### 2.5 Platform Implementation Change

定义：

- 只影响某一端的技术实现

常见例子：

- iOS 把约束改成新的布局方式
- Android 改 Compose 结构
- Web 改 CSS 实现

同步要求：

- 默认不同步到其它端

需要更新：

- 只更新当前端代码
- 如影响跨端理解，再补一条备注到相关文档

---

## 3. 同步决策表

| 变更类型 | 是否跨端同步 | 先改母版文档 | 是否改其它端代码 |
| --- | --- | --- | --- |
| Domain Change | 是 | 是 | 是 |
| API Contract Change | 是 | 是 | 是 |
| Design Token Change | 是 | 是 | 是 |
| Interaction Rule Change | 是 | 是 | 是 |
| Platform Implementation Change | 否 | 否 | 否 |

---

## 4. 标准流程

### 4.1 第一步：判断变更类型

任何提交前，先回答：

1. 这是 domain change 吗？
2. 这是 API change 吗？
3. 这是 design token change 吗？
4. 这是 interaction rule change 吗？
5. 如果都不是，它就是 platform implementation change

### 4.2 第二步：确定同步范围

按下列顺序判断：

- 只影响当前端
- 影响同类 feature
- 影响所有端共享规则

### 4.3 第三步：更新母版

如果属于跨端源事实，必须先更新：

- `docs/cross-platform/contracts/design/tokens.json`
- `docs/cross-platform/contracts/domain/*.schema.json`
- `docs/cross-platform/contracts/api/openapi.yaml`
- `docs/cross-platform/contracts/usecases/*.usecases.yaml`
- `docs/cross-platform/contracts/ui-state/*.yaml`
- `docs/cross-platform/contracts/routes/route-intents.yaml`
- `docs/cross-platform/contracts/fixtures/**/*`

按实际类型选择，不要求每次都改全部。

### 4.4 第四步：更新当前端

先保证最先修改的那一端实现正确。

### 4.5 第五步：同步其它端

按这个顺序更稳：

1. Android
2. HarmonyOS NEXT
3. Web
4. 其它候选端

原因：

- 当前 iOS 是结构母版
- Android 与 iOS 分层映射最直接，且已完成第一轮契约验收
- HarmonyOS NEXT 是 Android 完成后的下一优先级
- Web 和其它候选端更适合在 HarmonyOS NEXT 主链路后补齐

### 4.6 第六步：记录变更

每次跨端变更，至少记录：

- 来源提交
- 变更类型
- 影响范围
- 已同步端
- 待同步端

---

## 5. 变更记录模板

每次跨端变更，追加一条记录。

```md
## YYYY-MM-DD - Short Title

- Source:
  - commit: `abcdef0`
  - primary platform: `iOS`
- Change type:
  - `Design Token Change`
- Affected source of truth:
  - `Docs/cross-platform/design-tokens.md`
- Impact:
  - `accent.primary`
  - `background.vc`
  - `chart.blue`
- Synced:
  - [x] iOS
  - [x] Android
  - [ ] Web
  - [ ] Desktop
- Notes:
  - Android uses adaptive icon redraw instead of reusing iOS asset slices.
```

---

## 6. 当前已知基线记录

## 2026-05-08 - Blue AI Theme Refresh

- Source:
  - commit: `696d953`
  - primary platform: `iOS`
- Change type:
  - `Design Token Change`
- Affected source of truth:
  - `Docs/cross-platform/design-tokens.md`
- Impact:
  - `accent.primary`
  - `accent.secondary`
  - `bg.*`
  - `bg.grouped.*`
  - `label.*`
  - `separator.default`
  - `status.mark`
  - `chart.*`
  - `background.vc`
  - `background.list`
  - `action.send`
  - `action.checkSelected`
  - `action.likeSelected`
  - `action.unlikeSelected`
- Synced:
  - [x] iOS
  - [x] Android
  - [ ] Web
  - [ ] Desktop
- Notes:
  - Android 已建立 `apps/android/core/ui/theme` token 映射。
  - Web 与 Desktop 仍待映射。

## 2026-05-08 - Token Naming Fix

- Source:
  - primary platform: `iOS`
- Change type:
  - `Design Token Change`
- Affected source of truth:
  - `Docs/cross-platform/design-tokens.md`
- Impact:
  - `tertiary` naming normalization
- Synced:
  - [x] iOS
  - [x] Android
  - [ ] Web
  - [ ] Desktop
- Notes:
  - 禁止在新代码中继续使用 `tertiery` 拼写。

## 2026-05-09 - Mock API Environment Default

- Source:
  - primary platform: `iOS`
  - reference file: `app-ios/Packages/library-basics/Sources/Environment/AppEnvironmentValues.swift`
- Change type:
  - `Domain Change`
  - `API Contract Change`
- Affected source of truth:
  - `docs/cross-platform/contracts/domain/environment.schema.json`
  - `docs/cross-platform/contracts/api/openapi.yaml`
  - `docs/cross-platform/domain-models.md`
- Impact:
  - `MockApiEnvironment.defaultBaseUrl`
  - OpenAPI `servers[0].variables.baseUrl.default`
  - Android default `AI_DATA_INSIGHT_BASE_URL`
- Synced:
  - [x] iOS
  - [x] Android
  - [x] Web generated contract model
  - [ ] HarmonyOS NEXT
- Notes:
  - 默认学习环境统一为 Apifox mock host：`https://m1.apifoxmock.com/m1/3174267-1700689-default`。
  - 真实后端环境仍可通过平台环境配置覆盖。

## 2026-05-09 - AI Chat Stream Environment

- Source:
  - primary platform: `iOS`
  - reference file: `app-ios/Packages/module-ai/Sources/ModuleAI/Repositories/AIChat/DefaultAIChatRepository.swift`
  - environment file: `app-ios/Packages/library-basics/Sources/Environment/AppEnvironmentValues.swift`
- Change type:
  - `Domain Change`
  - `API Contract Change`
  - `Platform Implementation Change`
- Affected source of truth:
  - `docs/cross-platform/contracts/domain/environment.schema.json`
  - `docs/cross-platform/contracts/api/openapi.yaml`
  - `docs/cross-platform/domain-models.md`
- Impact:
  - `AIChatEndpoint.streamPath`
  - iOS `AIChatEndpoint.streamPath`
  - iOS `ChatApi.stream`
  - iOS `CommonRequester.requestSSE(RequestDescriptor)`
  - Android generated `AIChatEndpoint.StreamPath`
- Synced:
  - [x] iOS
  - [x] Android
  - [x] Web generated contract model
  - [ ] HarmonyOS NEXT
- Notes:
  - AI Chat SSE path 属于 AI Chat 子域，不能放进全局环境配置。
  - SSE URL 由平台网络层使用全局 `baseUrl` 和 AI Chat 领域 `streamPath` 组合得到，仓储层不能硬编码完整 URL，也不能直接引入底层 Networking 配置。

## 2026-05-09 - Login Adaptive Layout Contract

- Source:
  - primary platform: `Android`
  - reference file: `app-android/feature/login/src/main/java/com/aidatainsight/android/feature/login/ui/LoginScreen.kt`
  - reference platform behavior: iOS `safeAreaLayoutGuide` / `readableContentGuide`
- Change type:
  - `UI Layout Contract Change`
  - `Platform Implementation Learning`
- Affected source of truth:
  - `docs/cross-platform/contracts/ui-layout/login-layout.yaml`
  - `docs/cross-platform/contracts/ui-state/login-state.yaml`
  - `docs/ai-generation-guide.md`
- Impact:
  - 登录页背景必须 edge-to-edge，内容必须尊重 safe drawing area。
  - 竖屏使用单列布局，隐私协议默认在 home indicator / navigation area 上方可见。
  - 横屏 / regular 宽度使用品牌区 + 表单区双列布局，不能只是把竖屏 UI 缩窄居中。
  - 表单类页面必须使用 readable content width。
  - 协议勾选图标切换时不得出现与图标形状不匹配的默认方块高亮。
- Synced:
  - [x] Android
  - [ ] iOS
  - [ ] Web
  - [ ] HarmonyOS NEXT
- Notes:
  - 本次不是把 Android 实现上升为唯一标准，而是把 Android 适配过程中验证出来的跨端布局语义沉淀为契约。
  - Web 生成登录页时必须先读取 `ui-state/login-state.yaml` 和 `ui-layout/login-layout.yaml`，再选择 React / CSS 实现方式。

## 2026-05-09 - AI Home Shell Contract

- Source:
  - primary platform: `iOS`
  - reference file: `app-ios/Packages/module-ai/Sources/ModuleAI/Presentation/App/ContainerViewController.swift`
  - app entry file: `app-ios/Packages/library-common/Sources/AppMain/AppDelegate/AppDelegate.swift`
  - module router file: `app-ios/Packages/module-ai/Sources/ModuleAI/Presentation/App/ModuleAIRouter.swift`
- Change type:
  - `Domain Change`
  - `UseCase Contract Change`
  - `UI State Contract Change`
  - `UI Layout Contract Change`
- Affected source of truth:
  - `docs/cross-platform/contracts/domain/ai-home.schema.json`
  - `docs/cross-platform/contracts/usecases/ai-home.usecases.yaml`
  - `docs/cross-platform/contracts/ui-state/ai-home-state.yaml`
  - `docs/cross-platform/contracts/ui-layout/ai-home-layout.yaml`
  - `docs/cross-platform/contracts/fixtures/ui/ai-home-*.json`
  - `docs/cross-platform/contracts/routes/route-intents.yaml`
  - `docs/ai-generation-guide.md`
- Impact:
  - 登录成功后进入 AI Home，并替换登录作为主 app surface。
  - AI Home 默认主内容是 AI Chat。
  - History 是辅助面板/侧栏，打开时刷新历史列表，选择历史后关闭面板并让 Chat 在原位加载该会话。
  - 新会话动作清空 selectedHistoryId，并让 Chat 回到模板欢迎状态。
  - 删除当前历史或清空全部历史会让 Chat 回到新会话；删除非当前历史不影响 Chat。
  - Settings 是 AI Home 内的设置入口，由平台路由适配实现。
- Synced:
  - [x] iOS reference inspected
  - [ ] Android
  - [ ] Web
  - [ ] HarmonyOS NEXT
- Notes:
  - `ContainerViewController` 的 UIKit child-controller、navigation controller、transform 动画不是跨端源事实。
  - 跨端源事实是“已认证 AI 模块壳层 + 聊天主内容 + 历史辅助面板 + 设置入口 + 状态保持/切换规则”。

## 2026-05-09 - AI Home History Layering and Template Parsing

- Source:
  - primary platform: `Android`
  - reference behavior: AI Home 手势打开 History 面板时，背景、蒙层和面板容器需要全屏穿透，内容仍避让 safe area
  - reference API: `GET /chat/template`
- Change type:
  - `API Contract Change`
  - `UI Layout Contract Change`
  - `Contract Fixture Change`
  - `AI Generation Rule Change`
- Affected source of truth:
  - `docs/cross-platform/contracts/api/openapi.yaml`
  - `docs/cross-platform/api-contract.md`
  - `docs/cross-platform/domain-models.md`
  - `docs/cross-platform/contracts/ui-layout/ai-home-layout.yaml`
  - `docs/cross-platform/contracts/fixtures/api/chat-template-string-payload.json`
  - `docs/ai-generation-guide.md`
- Impact:
  - `/chat/template` 的领域输出固定为 `TemplateQuestionSet`，但接口 `data` 可兼容对象或内嵌 JSON 字符串。
  - 目标端必须在网络层或 AI Chat remote service 做归一化，不能让 Repository / UseCase / UI 直接处理接口字符串。
  - AI Home 中 History 面板的背景层、灰色蒙层和面板容器必须覆盖完整 viewport。
  - safe area 只应用于 History 内容，不应用于背景、蒙层或面板容器外层。
- Synced:
  - [x] Android
  - [ ] iOS
  - [ ] Web
  - [ ] HarmonyOS NEXT
- Notes:
  - Android 的 `ModalNavigationDrawer`、`ModalDrawerSheet`、`windowInsets` 只是发现问题的实现细节，不是跨端契约。
  - Web 生成时应映射为 CSS 层级：viewport 背景/overlay fixed 全屏，panel background full-height，panel content 使用 safe-area env padding。

## 2026-05-15 - Account Auto Login Contract

- Source:
  - primary platform: `Android`
  - reference behavior: 登录成功后持久化 token，杀死重启或重新运行时直接进入 AI Home
  - reference API: `POST /oauth2/login`
- Change type:
  - `Domain Change`
  - `API Contract Change`
  - `UseCase Contract Change`
  - `Contract Fixture Change`
  - `AI Generation Rule Change`
- Affected source of truth:
  - `docs/cross-platform/contracts/domain/account.schema.json`
  - `docs/cross-platform/contracts/api/openapi.yaml`
  - `docs/cross-platform/contracts/usecases/ai-home.usecases.yaml`
  - `docs/cross-platform/contracts/fixtures/api/login-response-snake-case.json`
  - `docs/cross-platform/domain-models.md`
  - `docs/cross-platform/api-contract.md`
  - `docs/ai-generation-guide.md`
- Impact:
  - 登录响应必须先归一化为 `AccountSession`，再持久化并触发进入 AI Home。
  - API DTO / remote service 必须兼容 `access_token` / `refresh_token` / `org_id`，领域层仍统一使用 `accessToken` / `refreshToken` / `orgId`。
  - 自动登录由启动时读取持久化 session 驱动，`isLogin` 由 `accessToken` 等可用 session 内容推导。
  - 登录成功、退出登录、会话失效都必须替换 root/main app surface，不能保留受保护页面的返回栈。
- Synced:
  - [x] Android
  - [ ] iOS reference already has equivalent behavior
  - [ ] Web
  - [ ] HarmonyOS NEXT
- Notes:
  - 本次问题证明“登录接口返回 200”不足以支撑自动登录；token 字段解析、session store 和启动路由必须作为一条主链路一起生成。

## 2026-05-15 - Setting Screen Contract

- Source:
  - primary platform: `iOS`
  - validation platform: `Android`
  - reference files:
    - `app-ios/Packages/library-common/Sources/Setting/SettingViewController.swift`
    - `app-ios/Packages/library-common/Sources/Setting/Presentation/ViewModels/SettingViewModel.swift`
    - `app-android/feature/setting/src/main/java/com/aidatainsight/android/feature/setting/ui/SettingScreen.kt`
- Change type:
  - `Domain Change`
  - `UseCase Contract Change`
  - `UI State Contract Change`
  - `UI Layout Contract Change`
  - `Contract Fixture Change`
  - `AI Generation Rule Change`
- Affected source of truth:
  - `docs/cross-platform/contracts/domain/setting.schema.json`
  - `docs/cross-platform/contracts/usecases/setting.usecases.yaml`
  - `docs/cross-platform/contracts/ui-state/setting-state.yaml`
  - `docs/cross-platform/contracts/ui-layout/setting-layout.yaml`
  - `docs/cross-platform/contracts/fixtures/ui/setting-*.json`
  - `docs/cross-platform/domain-models.md`
  - `docs/ai-generation-guide.md`
- Impact:
  - Setting 固定为已认证页面，采用分组列表语义。
  - 账户分组展示昵称、登录名、手机号；空值显示 `未设置`。
  - 关于分组展示隐私政策和 App 版本。
  - 退出登录单独成组，红色居中，必须先弹确认框。
  - iOS SF Symbols 不是跨端源事实；Android/Web 没有明确匹配图标时应省略图标，不能用文字占位。
- Synced:
  - [x] iOS reference inspected
  - [x] Android
  - [ ] Web
  - [ ] HarmonyOS NEXT
- Notes:
  - 本次沉淀的源事实是 Setting 的领域快照、行语义、动作和布局意图，不是 UITableView、Compose LazyColumn 或某个平台的图标系统。

## 2026-05-15 - History Screen Contract and Android Validation

- Source:
  - primary platform: `iOS`
  - validation platform: `Android`
  - reference files:
    - `app-ios/Packages/module-ai/Sources/ModuleAI/Presentation/History/ViewControllers/HistoryViewController.swift`
    - `app-ios/Packages/module-ai/Sources/ModuleAI/Presentation/History/ViewData/HistoryListViewData.swift`
    - `app-android/feature/history/src/main/java/com/aidatainsight/android/feature/history/ui/HistoryScreen.kt`
- Change type:
  - `Domain Change`
  - `UseCase Contract Change`
  - `UI State Contract Change`
  - `UI Layout Contract Change`
  - `Contract Fixture Change`
  - `Android Implementation Change`
- Affected source of truth:
  - `docs/cross-platform/contracts/domain/history.schema.json`
  - `docs/cross-platform/contracts/usecases/history.usecases.yaml`
  - `docs/cross-platform/contracts/ui-state/history-state.yaml`
  - `docs/cross-platform/contracts/ui-layout/history-layout.yaml`
  - `docs/cross-platform/contracts/fixtures/ui/history-initial.json`
  - `docs/cross-platform/domain-models.md`
  - `docs/ai-generation-guide.md`
- Impact:
  - History 标题固定为 `历史会话`。
  - 分组标题固定为 `今天` / `本月` / `其它`。
  - 行展示会话名称和时间，删除入口改为长按/secondary action。
  - 当前参考 UI 不暴露刷新和清空全部作为顶部常驻按钮。
  - Android 已按契约还原为气泡式历史会话列表。
- Synced:
  - [x] iOS reference inspected
  - [x] Android
  - [ ] Web
  - [ ] HarmonyOS NEXT
- Notes:
  - iOS 的 UITableView、MenuViewController 和图片资源不是跨端源事实；跨端源事实是历史分组、行语义、时间显示和交互动作。

## 2026-05-15 - AIChat Screen Contract and Android Validation

- Source:
  - primary platform: `iOS`
  - validation platform: `Android`
  - reference files:
    - `app-ios/Packages/module-ai/Sources/ModuleAI/Presentation/AIChat/ViewControllers/AIChatViewController.swift`
    - `app-ios/Packages/module-ai/Sources/ModuleAI/Presentation/AIChat/Views/AIChatBottomView.swift`
    - `app-android/feature/ai-chat/src/main/java/com/aidatainsight/android/feature/aichat/ui/AIChatScreen.kt`
- Change type:
  - `UI State Contract Change`
  - `UI Layout Contract Change`
  - `Android Implementation Change`
- Affected source of truth:
  - `docs/cross-platform/contracts/ui-state/ai-chat-state.yaml`
  - `docs/cross-platform/contracts/ui-layout/ai-chat-layout.yaml`
  - `docs/cross-platform/domain-models.md`
  - `docs/ai-generation-guide.md`
- Impact:
  - AIChat 使用 `background_vc` 语义背景图。
  - 模板问题显示为 AI 欢迎气泡，并包含推荐问题和问题拆解示例。
  - Android 已按契约还原用户/AI 气泡、底部胶囊输入区和推荐问题点击发送行为。
  - 图表 fallback 文案继续固定为 `数据分析还在测试阶段，很快就能上线，敬请期待！`。
- Synced:
  - [x] iOS reference inspected
  - [x] Android
  - [ ] Web
  - [ ] HarmonyOS NEXT
- Notes:
  - iOS 的 UIKit cell、图片按钮和 SF Symbols 不是跨端源事实；跨端源事实是 AIChat 的背景语义、消息布局、欢迎内容、输入行为和错误兜底。

## 2026-05-15 - AIChat Chart and Feedback Contract

- Source:
  - primary platform: `iOS`
  - validation platform: `Android`
  - reference files:
    - `app-ios/Packages/module-ai/Sources/ModuleAI/Presentation/AIChat/Views/AIChatChartCell.swift`
    - `app-ios/Packages/module-ai/Sources/ModuleAI/Presentation/AIChat/Views/AIChatLegendChartCell.swift`
    - `app-ios/Packages/module-ai/Sources/ModuleAI/Presentation/AIChat/Views/AIChatFeedbackView.swift`
    - `app-android/feature/ai-chat/src/main/java/com/aidatainsight/android/feature/aichat/ui/AIChatScreen.kt`
- Change type:
  - `UI Layout Contract Change`
  - `UI State Contract Change`
  - `Android Implementation Change`
- Impact:
  - Chart message 必须从 `ChartPayload` 渲染，不允许 UI 解析或显示 raw API JSON。
  - 普通图表渲染为柱状图，多值图表渲染为堆叠柱状图，单位按“万”展示。
  - 图表生成后必须滚动到 transcript 底部锚点，确保图表和反馈区可见。
  - 反馈只在 chart message 有 `historyDetailId` 时显示；请求值固定为 `"1"` / `"0"`，失败回滚。
  - `UIImage.imageNamed` 是可跨端同步的项目资产；`UIImage(systemName:)` / SF Symbols 是 iOS 平台装饰。
- Synced:
  - [x] iOS reference inspected
  - [x] Android
  - [ ] Web
  - [ ] HarmonyOS NEXT

---

## 7. 给 AI 的执行规则

以后让 AI 协助多端同步时，任务描述优先写成：

- “这是一次 `Design Token Change`，先更新 `design-tokens.md`，再同步 Android theme”
- “这是一次 `Domain Change`，先更新领域模型母版，再同步 iOS/Android”
- “这是一次 `Platform Implementation Change`，只改 Android，不同步其它端”

避免写成：

- “把这个页面顺手同步到其它端”
- “iOS 改完了，帮我都改一下”

前一种表达能让 AI 稳定按规则执行，后一种表达会把平台实现和跨端源事实混在一起。

---

## 一句话结论

四端同步不是“看到一端改了，就去抄另外三端”，而是“先确认这次改动是不是跨端源事实，再按固定顺序更新母版和各端实现”。
