# HarmonyOS NEXT 适配执行清单

这份文档用于给 AI 在中断后恢复 HarmonyOS NEXT 适配任务时读取。目标是避免上下文过长后忘记当前阶段、顺序和边界。

## 当前目标

当前多端优先级是：

```text
iOS -> Android -> HarmonyOS NEXT -> Web -> 其它候选端
```

iOS 和 Android 已完成主要功能。HarmonyOS NEXT 是下一阶段目标，第一版仍面向学习项目和 mock 环境，不连接真实生产后端。

## 当前执行状态

- [x] 阶段 1 已建立 `app-harmony` 源码骨架、模块边界文档、路由占位和页面占位。
- [ ] DevEco 工程配置待从已经跑通的模板工程迁入，避免手写版本敏感的 `json5` 配置。
- [x] 阶段 2 已接入 ArkTS contract models 生成，输出到 `app-harmony/entry/src/main/ets/contracts/generated/ContractModels.ets`。
- [x] 阶段 3 已补最小 contract mapper 和基于 golden fixtures 的本地单测。
- [x] 阶段 4 已建立 HarmonyOS NEXT core 基础层。
- [x] 阶段 5 已接入 Login mock 登录和自动登录导航。
- [x] 阶段 6 已补 AIHome 壳层。
- [x] 阶段 7 已补 Setting / Privacy 链路。
- [x] 阶段 8 已补 History 链路。
- [x] 阶段 9 已补 AIChat 链路。

## 总原则

- 先读 `docs/ai-generation-guide.md` 和 `docs/cross-platform/contracts/README.md`。
- HarmonyOS NEXT 只能从已验证契约生成，不能从 iOS UIKit 或 Android Compose 页面反推。
- 先做可编译、可运行、可验证的最小链路，再追 UI 还原。
- 没有真机时，必须说明真机能力、性能和发布链路未验证。
- ArkTS 不是 TypeScript，不能直接复制 Web 代码。

## 执行阶段

### 0. 环境与边界

- 安装 DevEco Studio。
- 创建空 HarmonyOS NEXT 工程并跑通 Hello World。
- 确认包名、应用名、SDK/API 版本、模拟器或真机验证方式。
- 明确第一版只使用 mock 环境。

### 1. 工程骨架

- 新建 `app-harmony`。
- 建立基础目录和命名边界：
  - `app`
  - `core/model`
  - `core/network`
  - `core/account`
  - `core/ui`
  - `feature/login`
  - `feature/setting`
  - `feature/privacy`
  - `feature/history`
  - `feature/ai-chat`
- 先建 Login、AIHome、Setting、Privacy、History、AIChat 占位页面和路由。

### 2. 契约生成

- `scripts/generate-cross-platform-contracts.sh` 已增加 ArkTS contract models 输出。
- 目标路径：

```text
app-harmony/entry/src/main/ets/contracts/generated/ContractModels.ets
```

- 先只生成模型，不生成页面。
- ArkTS 生成物不要直接复制 Web TypeScript：保留同一契约语义，但使用 ArkTS 可维护的 `enum`、`interface` 和显式 helper function。
- 运行 contract validation。

### 3. Mapper Tests / Golden Fixtures

- 优先复用现有 `docs/cross-platform/contracts/fixtures`。
- 先覆盖：
  - `AccountSession`
  - `SettingSnapshot`
  - `HistoryRecord`
  - `AIChatMessage`
  - `FunctionName -> FunctionArguments`
  - `ChartPayload`
- 当前已落地最小覆盖：
  - snake_case 登录 token -> `AccountSession`
  - `/chat/template` 字符串 JSON -> `TemplateQuestionSet`
  - History 文本详情 -> `ConversationMessage`
  - History 图表详情 -> `ChartPayload`
  - Chart fixture -> `ChartSeries`

### 4. Core 层

- `core:model`：接 generated models。
- `core:network`：封装 mock baseURL、请求、响应外壳、错误处理。
- `core:account`：登录态、session store、自动登录判断。
- `core:ui`：颜色、背景、安全区、通用按钮、列表样式。
- 当前已落地：
  - `core/model/ContractModelExports.ets`
  - `core/network/ApiEnvironmentProvider.ets`
  - `core/network/CommonRequester.ets`
  - `core/network/ApiEnvelope.ets`
  - `core/network/ApiError.ets`
  - `core/network/MockHttpTransport.ets`
  - `core/account/AccountSessionStore.ets`
  - `core/account/AccountAuthService.ets`
  - `core/ui/theme/AppTheme.ets`
  - `core/ui/components/*`

### 5. Login

- 按契约还原登录页。
- 接 mock 登录接口。
- 保存 session。
- 启动时自动登录进入 AIHome。
- Privacy 链接先打开本地 HTML 或内置静态页面。
- 当前已落地：
  - `feature/login/application/LoginState.ets`
  - `feature/login/pages/LoginPage.ets`
  - `app/services/AppServices.ets`
  - `pages/Index.ets` 启动时读取 `AccountAuthService.canAutoLogin()`
  - mock 登录路径使用 OpenAPI 契约中的 `/oauth2/login`

### 6. AIHome

- 登录成功后进入 AIHome。
- AIHome 管理：
  - AIChat 主内容
  - History 面板或页面
  - Setting 入口
  - 新会话
- 先保证状态切换语义，不急着完整还原动画。
- 当前已落地：
  - `app/pages/AIHomePage.ets` 作为 authenticated module shell。
  - AIChat 是主 surface，接收 `selectedHistoryId` 和新会话版本。
  - History 是辅助 overlay panel，不替换主 Chat。
  - History 选择会话后关闭面板，并把 historyId 传给 AIChat。
  - History 面板设置入口路由到 Setting。
  - 新会话清空 `selectedHistoryId` 并递增 conversation version。

### 7. Setting / Privacy

- Setting 展示账户信息、隐私政策、版本号、退出登录。
- 退出登录清 session，并替换回 Login。
- Privacy 先保证可打开、可返回、中文可显示。
- 当前已落地：
  - `feature/setting/application/SettingState.ets`
  - `feature/setting/pages/SettingPage.ets`
  - `feature/privacy/application/PrivacyContent.ets`
  - `feature/privacy/pages/PrivacyPage.ets`
  - Setting 隐私入口路由到 Privacy。
  - Setting 退出登录清 session 并回 Login。

### 8. History

- 接历史列表 mock 接口。
- 分组规则沿用契约：今天、昨天、其它。
- 有数据时无感刷新。
- 选择历史后关闭 History，让现有 AIChat 加载该会话，不新开 Chat 页面。
- 当前已落地：
  - `feature/history/application/HistoryRepository.ets`
  - `feature/history/application/HistoryRuntime.ets`
  - `feature/history/application/HistoryState.ets`
  - `feature/history/pages/HistoryPage.ets`
  - mock 数据按“今天 / 本月 / 其它”分组。
  - History 面板打开时刷新；已有数据时不显示阻塞 loading。
  - 选择历史会话后关闭面板，并把 historyId 传给 AIChat。

### 9. AIChat

- 加载模板问题。
- 实现输入、发送、清空、新会话。
- 接流式 mock。
- 图表 fallback 文案固定为：

```text
数据分析还在测试阶段，很快就能上线，敬请期待！
```

- 再补图表和反馈按钮。
- 当前已落地：
  - `feature/ai_chat/application/AIChatRepository.ets`
  - `feature/ai_chat/application/AIChatRuntime.ets`
  - `feature/ai_chat/application/AIChatState.ets`
  - `feature/ai_chat/pages/AIChatPage.ets`
  - mock 模板问题、历史详情、函数分析、图表数据、流式文本和反馈状态。
  - AIHome 传入 `selectedHistoryId` 时加载历史会话，开始新会话时重置并加载模板问题。

### 10. 收尾

- 补 `app-harmony/README.md`。
- 更新 `docs/ai-generation-guide.md` 中 HarmonyOS NEXT 的实际工程路径。
- 更新 `docs/cross-platform/change-log.md`。
- 运行 contract validation。
- 做工程卫生。

## 下一步建议

第一步先做：

```text
创建 app-harmony 工程骨架 + README + 空页面路由 + generated models 目标路径设计
```

先固定 AI 以后往哪里生成代码，再开始生成业务。
