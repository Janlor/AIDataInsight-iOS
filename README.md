# AIDataInsight

AIDataInsight 是一个 AI 驱动的数据分析多端应用项目。

项目的核心目标不是“手写多套互相漂移的端侧代码”，而是先设计一套稳定的领域模型、API 契约、业务用例和设计规则，再让 AI 基于这套契约辅助生成 iOS、Android、HarmonyOS NEXT、Web 以及未来候选端实现。

当前 iOS、Android 和 HarmonyOS NEXT 已完成主要功能开发，并逐步沉淀为参考实现、契约验收端和 ArkUI 原生实现端；Web 排在 HarmonyOS NEXT 之后；macOS、Windows 等端暂作为后续候选方向评估。

## 项目理念

AIDataInsight 的多端开发路线是：

```text
contracts -> generated models -> repository -> usecase -> UI state mapper -> UI
```

也就是说，真正跨端共享的不是 UIKit、Compose、React 或 ArkUI 页面代码，而是：

- 领域模型
- API 契约
- 业务用例
- 动态函数参数规则
- 错误和会话规则
- 路由意图
- 设计 token
- golden fixtures / contract tests

iOS 当前是参考实现，但不是其它端照抄的来源。Android / HarmonyOS NEXT / Web / 未来候选端都应该从 `docs/cross-platform/contracts` 出发，而不是从 iOS 页面、Cell 或 ViewData 反推业务模型。

## 当前端侧策略

当前优先级：

```text
P0 iOS：已完成主要功能，继续稳定和契约化
P1 Android：已完成主要功能，继续作为契约验收端
P2 HarmonyOS NEXT：已完成主要功能开发，后续以 bugfix 和体验优化为主
P3 Web：HarmonyOS NEXT 完成后再推进，先保留 contract models
P4 macOS：短期靠 iPadOS 兼容模式，SwiftUI 化后再看
P5 Windows：暂不规划，未来优先 Web / PWA
```

更完整的端侧适配建议见：

- [docs/architecture/platform-adaptation-strategy.md](docs/architecture/platform-adaptation-strategy.md)

## 业务主链路

项目围绕“自然语言提问 -> AI 理解 -> 函数参数解析 -> 数据查询 -> 图表展示 / 对话反馈”这条链路展开。

核心链路包括：

### 函数调用 / 图表分析链路

```text
用户输入
-> Function Analysis
-> FunctionName
-> FunctionArguments
-> /chart/{functionName}
-> HistoryChartDetail
-> ChartPayload
-> 各端图表 UI
```

这条链路已经被固化到契约中：

- `docs/cross-platform/contracts/usecases/ai-chat.usecases.yaml`
- `docs/cross-platform/contracts/domain/ai-chat.schema.json`
- `docs/cross-platform/contracts/fixtures/function-response/*.json`

### 流式回复链路

```text
用户输入
-> StreamAIResponseUseCase
-> SSE / Stream
-> chunk 累积
-> 各端渲染节流
-> 对话气泡增量展示
```

iOS 端当前已落地流式响应和打字机式渲染，Android 已按同一 use case 语义映射到 `Flow`；HarmonyOS NEXT 当前按完整响应解析 `/stream` 的 `data:` 内容并一次性展示，实时 SSE / 打字机可作为后续体验优化；Web 后续再映射到 `ReadableStream` / async iterator。

## 架构分层

项目按四层理解：

```text
App Shell
Platform Layer
Application Layer
Domain + Data Layer
```

### App Shell

负责：

- 应用入口
- 生命周期
- 模块装配
- 全局导航入口

### Platform Layer

负责：

- 平台路由
- 系统权限
- Keychain / 本地安全存储
- 外部链接
- 平台 UI 基础能力

### Application Layer

负责：

- use case
- 页面状态编排
- 业务流程
- application output

要求：

- 不返回 UIKit / Compose / React / ArkUI UI model
- 不依赖 Controller / View / Cell
- 不直接处理平台控件状态

### Domain + Data Layer

负责：

- 领域实体
- 值对象
- repository 协议
- API DTO
- DTO -> domain mapper
- 动态函数参数解析

## 当前工程结构

```text
AIDataInsight
├── app-ios/                 # iOS App、Swift Package 模块和 iOS 专属文档
├── app-android/             # Android Gradle 多模块工程
├── app-harmony/             # HarmonyOS NEXT DevEco / ArkTS 原生工程
├── app-web/                 # Web contract generated models，后续扩展为 Web 工程
├── docs/
│   ├── architecture/        # 架构、端侧策略、演进方案
│   └── cross-platform/      # 跨平台契约说明与机器可读契约包
├── images/                  # README 截图
└── scripts/                 # 契约校验、生成和图文档导出脚本
```

## 端侧入口

各端 README 负责说明本端工程结构、运行方式和实现细节：

- iOS 端说明：[app-ios/README.md](app-ios/README.md)
- Android 端说明：[app-android/README.md](app-android/README.md)
- HarmonyOS NEXT 端说明：[app-harmony/README.md](app-harmony/README.md)
- Web 端说明：[app-web/README.md](app-web/README.md)

iOS 端是当前最完整的参考实现。iOS 专属架构设计、Networking 定稿和组件依赖关系图已经移到 [app-ios/docs](app-ios/docs)，根 README 不再重复展开这些端侧细节。

## Android 当前状态

Android 端已完成主要功能，并作为契约回归端继续使用：

```text
app-android
├── app                 # Android app 壳、导航、AIHome 组合入口
├── core
│   ├── common          # 通用基础代码
│   ├── model           # 契约生成模型
│   ├── network         # Ktor Client、remote service、API 响应处理
│   ├── account         # 登录态、账号会话、账号 remote service
│   ├── ui              # 主题、通用背景、共享 UI token
│   └── testing         # 测试辅助
└── feature
    ├── login
    ├── setting
    ├── privacy
    ├── history
    └── ai-chat
```

当前状态：

- `app-android/core/model/src/main/java/com/aidatainsight/android/core/model/contract/ContractModels.kt`
- Login / Setting / Privacy / History / AIChat / AIHome 已有 Compose 实现
- `core:network`、`core:account` 已接入 Apifox mock 环境
- 自动登录、本地 Privacy HTML、主要 ViewModel / UseCase / 导航测试已覆盖
- 后续以契约回归、缺陷修复和体验打磨为主

推荐技术栈：

- Kotlin
- Jetpack Compose
- Navigation Compose
- Coroutines + Flow
- Kotlinx Serialization
- Ktor Client 或 Retrofit

## HarmonyOS NEXT 当前状态

HarmonyOS NEXT 已完成主要功能开发。工程已接入 DevEco Studio / ArkTS / ArkUI，并按契约生成、core 基础层和 feature 链路落地。

当前已完成：

- DevEco 工程骨架与 `entry/src/main/ets` 模块边界
- ArkTS contract models 生成：`app-harmony/entry/src/main/ets/contracts/generated/ContractModels.ets`
- 最小 contract mapper tests / golden fixture tests
- `core:model`、`core:network`、`core:account`、`core:ui`
- Login mock 登录、隐私入口、启动自动登录导航
- AIHome 壳层：AIChat 主 surface、History 面板、Setting route
- Setting / Privacy 链路：账户信息、隐私政策、退出登录
- History mock 列表链路：今天 / 本月 / 其它分组、无感刷新、选择会话
- AIChat Apifox mock 链路：模板问题、输入发送、`/stream` 返回文本展示、图表 fallback 和反馈状态
- 阶段 10 收尾：端侧 README、执行清单、AI 生成指南、change log 和工程卫生

推荐技术栈：

- ArkTS
- ArkUI 声明式 UI
- DevEco Studio
- 官方网络能力或项目统一网络封装
- DevEco Studio 单元测试 / UI 测试 / 模拟器验证

当前开源版本默认使用 Apifox mock 环境；后续 HarmonyOS 工作以 bugfix、UI 细节和 SSE 体验优化为主。

## Web 当前状态

Web 端目前已生成 TypeScript contract models，但完整 Web 工程排在 HarmonyOS NEXT 之后：

- `app-web/src/contracts/generated/models.ts`

后续建议技术栈：

- TypeScript
- Next.js App Router
- React
- TanStack Query 或 fetch 封装
- ECharts 或 AntV
- Vitest / Testing Library / Playwright

## 桌面端

macOS 当前可以通过 iPadOS 兼容模式运行 iOS App。未来如果 UIKit 逐步迁移 SwiftUI，可再评估 macOS 原生 target。

Windows 暂不规划。如果未来确实需要桌面端，优先考虑 Web / PWA / Tauri / Electron。

## 跨平台契约包

机器可读契约位于：

- [docs/cross-platform/contracts](docs/cross-platform/contracts)

契约包包括：

```text
contracts/
  domain/       JSON Schema 领域模型
  api/          OpenAPI API 契约
  usecases/     UseCase 输入、输出和业务规则
  ui-state/     平台中立 UI state
  routes/       路由意图
  design/       设计 token
  fixtures/     golden fixtures / contract tests
```

运行契约校验：

```bash
scripts/validate-cross-platform-contracts.sh
```

生成 Android / HarmonyOS NEXT / Web contract models：

```bash
scripts/generate-cross-platform-contracts.sh
```

## AI 生成协议

AI 生成端侧代码时必须遵守固定协议：

- [docs/ai-generation-guide.md](docs/ai-generation-guide.md)

简化流程：

```text
1. 读取 contracts/domain
2. 读取 contracts/api
3. 读取 contracts/usecases
4. 读取 contracts/ui-state
5. 读取 fixtures
6. 读取目标端模块映射
7. 生成 repository
8. 生成 data / mapper
9. 生成 usecase
10. 生成 UI state mapper
11. 最后生成 UI
12. 跑 contract tests 和目标端测试
```

## 重要文档

- iOS 端说明：[app-ios/README.md](app-ios/README.md)
- iOS 专属文档：[app-ios/docs](app-ios/docs)
- 多端适配建议：[docs/architecture/platform-adaptation-strategy.md](docs/architecture/platform-adaptation-strategy.md)
- HarmonyOS NEXT 适配清单：[docs/architecture/harmonyos-next-implementation-plan.md](docs/architecture/harmonyos-next-implementation-plan.md)
- AI 生成协议：[docs/ai-generation-guide.md](docs/ai-generation-guide.md)
- 跨平台蓝图：[docs/architecture/cross-platform-blueprint.md](docs/architecture/cross-platform-blueprint.md)
- 领域模型说明：[docs/cross-platform/domain-models.md](docs/cross-platform/domain-models.md)
- API 契约说明：[docs/cross-platform/api-contract.md](docs/cross-platform/api-contract.md)
- 设计 token：[docs/cross-platform/design-tokens.md](docs/cross-platform/design-tokens.md)

## Demo

<img src="./images/history.png" width="402"> <img src="./images/chat.png" width="402">

## 说明

- 当前仓库以 AI 数据分析 Demo、多端架构设计和契约驱动生成实践为主
- iOS 已经具备完整参考实现
- iOS / Android / HarmonyOS NEXT 已完成主要功能开发，之后再推进 Web
- 当前默认环境使用 Apifox mock；HarmonyOS NEXT 的 `/stream` 当前一次性展示解析结果，实时 SSE 可作为后续体验优化
- macOS、Windows 暂不作为当前阶段强目标
