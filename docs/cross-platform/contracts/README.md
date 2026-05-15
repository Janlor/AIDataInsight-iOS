# AIDataInsight 跨平台契约包

这个目录是 iOS、Android、Web 以及未来候选端共享的机器可读契约包。

`docs/cross-platform` 下的 Markdown 文档负责解释设计意图和背景；本目录下的文件是多端生成代码和手写镜像实现的源事实。

## 契约结构

```text
contracts/
  domain/       共享领域模型的 JSON Schema。
  api/          HTTP 接口和响应外壳的 OpenAPI 契约。
  usecases/     跨端 Application / UseCase 的输入、输出和规则。
  ui-state/     平台中立的 UI state 形状。
  ui-layout/    平台中立的页面布局语义、响应式规则和安全区策略。
  routes/       共享路由意图词表。
  design/       机器可读的设计 token。
  fixtures/     多端 contract tests 共用的 golden examples。
```

## 更新规则

任何跨端变更都按下面顺序处理：

1. 先从 iOS 真实实现提炼相关契约草案。
2. 更新机器可读契约、解释文档和必要 fixtures。
3. 按契约生成或调整 Android。
4. 用 Android 运行验证契约是否足够清晰。
5. 如果 Android 暴露跨端问题，先回写契约和 fixtures，再修正 Android。
6. Web 和后续端只从已验证契约生成，不能从 iOS 或 Android 页面反推。
7. 最后在 `docs/cross-platform/change-log.md` 记录这次变更。

简写流程：

```text
iOS reference -> contract draft -> Android validation -> contract refinement -> Web generation
```

注意：Android 验证后回写契约不是事后补文档，而是把契约从草案升级为已验证源事实。

## 契约测试

在仓库根目录运行 golden fixture 校验器：

```sh
ruby scripts/validate-cross-platform-contracts.rb
```

校验器会检查：

- 所有 JSON / YAML 契约文件都可以解析；
- `FunctionName` 在 JSON Schema、动态 use case 契约和 iOS `FunctionName.swift` 三处一致；
- 动态函数响应 fixtures 能解析到预期的参数类型和 use case 分支；
- 图表 fixtures 能映射到预期的 `/chart/{functionName}` 请求和 `ChartPayload`；
- 历史详情 fixtures 不会把内嵌 JSON 泄漏为用户可见文本；
- 登录 mock 的 snake_case token 字段能归一化为 `AccountSession`，并支持自动登录；
- `401` / `402` fixtures 能映射到预期的会话处理动作。

## Android / Web 生成

Android 和 Web 必须消费由契约生成的模型，不能复制 iOS UIKit 展示模型，也不能从 iOS 页面行为反推业务事实。

完整的 AI 生成流程见 `docs/ai-generation-guide.md`。

在仓库根目录运行：

```sh
scripts/generate-cross-platform-contracts.sh
```

生成产物：

- `app-android/core/model/src/main/java/com/aidatainsight/android/core/model/contract/ContractModels.kt`
- `app-web/src/contracts/generated/models.ts`
- `docs/cross-platform/contracts/generated-manifest.json`

规则：

- 不要手改生成文件。
- 如果生成类型不对，先更新 `contracts/`，再重新生成。
- Android Compose UI 应该把生成的 contract / application models 映射成本端 UI state。
- Web React UI 应该把生成的 TypeScript contract / application models 映射成本端 UI state。
- 没有设计稿时，iOS / Android 的真实实现只能用于提炼 UI state、UI layout、interaction rules、display text 和 golden fixtures；提炼完成后，各端以契约为准。
- UI layout 契约只描述跨端布局意图，例如 safe area、readable width、响应式分栏、滚动和交互反馈；不能写入 UIKit Auto Layout、Compose Modifier 或 React DOM 结构。
- Android 和 Web 都不能把 iOS 的 `AIChat`、`AIBarChartData`、`HistorySectionViewData`、UIKit Cell 或 Controller 行为当作源事实。

## 第一版覆盖范围

`0.1.0` 版本覆盖：

- Account / Setting 领域模型。
- Setting use case / UI state / UI layout 契约，用于约束账户信息、关于、退出登录确认、可选图标和分组列表语义。
- Account 自动登录规则：登录响应 token 归一化、session 持久化、启动读取 session、登录/退出/会话失效后的 root route 替换。
- Environment 领域模型，包含多端默认学习环境使用的 Apifox mock host。
- AI Home 领域模型，描述登录成功后的 AI 业务主入口、内容切换和辅助面板语义。
- AI Chat endpoint 领域模型，包含流式接口路径等子域 API 语义。
- AI Chat 函数分析领域模型。
- History 领域模型。
- 共享 API 响应外壳和 AI / History / Account 核心接口。
- AI Chat template 的兼容解析约束：`/chat/template` 的 `data` 可为对象或内嵌 JSON 字符串，但应用层统一看到 `TemplateQuestionSet`。
- AI Home / AI Chat / History use case 契约。
- 平台中立的 AI Chat / History / Login UI state。
- 平台中立的 Setting UI state，用于约束分组、行文案、隐私入口、版本展示和退出确认。
- 平台中立的 AI Home UI state，用于组合 AIChat、History 和 Settings 入口。
- Login UI layout 契约，用于约束沉浸式背景、安全区、竖屏单列、横屏双列、readable width、滚动和协议勾选反馈。
- Setting UI layout 契约，用于约束分组列表、readable width、安全区、退出确认和无合适图标时省略图标。
- AI Home UI layout 契约，用于约束登录成功后的主入口、聊天主内容、历史辅助面板、设置入口、安全区、键盘避让、背景/蒙层/面板全屏穿透和响应式分栏。
- History UI layout 契约，用于约束历史会话标题、分组、气泡行、长按删除、设置入口和非阻塞刷新。
- AI Chat golden UI fixtures，用于约束初始、模板、发送、意图、图表、fallback 和流式状态。
- AI Home golden UI fixtures，用于约束登录后进入 AI 主入口、打开历史面板、选择历史会话和开始新会话。
- History golden UI fixtures，用于约束历史会话分组列表、顶部操作和删除入口。
- Login golden UI fixtures，用于约束 iOS demo 默认值、隐私协议、loading 和按钮可用状态。
- Setting golden UI fixtures，用于约束加载后的分组列表和退出确认状态。
- 共享路由意图。
- 设计 token。

当前契约包有意优先聚焦 `AIChat` 和 `History`，因为这两块最容易在多端实现中发生语义漂移。
