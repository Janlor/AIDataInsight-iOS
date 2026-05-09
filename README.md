# AIDataInsight

AIDataInsight 是一个 AI 驱动的数据分析多端应用项目。

项目的核心目标不是“手写多套互相漂移的端侧代码”，而是先设计一套稳定的领域模型、API 契约、业务用例和设计规则，再让 AI 基于这套契约辅助生成 iOS、Android、Web 以及未来候选端实现。

当前 iOS 端已完成主要功能开发，并逐步沉淀为参考实现；Android 和 Web 正在按同一份契约启动；鸿蒙、macOS、Windows 等端暂作为后续候选方向评估。

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

iOS 当前是参考实现，但不是其它端照抄的来源。Android / Web / 未来鸿蒙端都应该从 `docs/cross-platform/contracts` 出发，而不是从 iOS 页面、Cell 或 ViewData 反推业务模型。

## 当前端侧策略

当前优先级：

```text
P0 iOS：已完成主要功能，继续稳定和契约化
P1 Android：第二优先级，先跑通主链路
P2 Web：第三优先级，先跑通主链路
P3 鸿蒙：候选端，等前三端后评估
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

iOS 端当前已落地流式响应和打字机式渲染，Android / Web 后续会按同一 use case 语义分别映射到 `Flow` 和 `ReadableStream` / async iterator。

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
- Web 端说明：[app-web/README.md](app-web/README.md)

iOS 端是当前最完整的参考实现。iOS 专属架构设计、Networking 定稿和组件依赖关系图已经移到 [app-ios/docs](app-ios/docs)，根 README 不再重复展开这些端侧细节。

## Android 当前状态

Android 端已建立基础脚手架：

```text
app-android
├── app
├── core
│   ├── common
│   ├── model
│   ├── network
│   ├── account
│   ├── ui
│   └── testing
└── feature
    ├── login
    ├── setting
    ├── privacy
    ├── history
    └── ai-chat
```

当前已经可以从契约生成 Android contract models：

- `app-android/core/model/src/main/java/com/aidatainsight/android/core/model/contract/ContractModels.kt`

推荐技术栈：

- Kotlin
- Jetpack Compose
- Navigation Compose
- Coroutines + Flow
- Kotlinx Serialization
- Ktor Client 或 Retrofit

## Web 当前状态

Web 端目前已生成 TypeScript contract models：

- `app-web/src/contracts/generated/models.ts`

后续建议技术栈：

- TypeScript
- Next.js App Router
- React
- TanStack Query 或 fetch 封装
- ECharts 或 AntV
- Vitest / Testing Library / Playwright

## 鸿蒙与桌面端

鸿蒙暂作为候选端，建议等 iOS / Android / Web 三端主链路完成后再评估。

推荐评估路线：

```text
contracts -> ArkTS models -> mapper tests -> mock page -> repository -> network -> 真机验证
```

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

生成 Android / Web contract models：

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
- Android / Web 正在从契约生成和脚手架逐步推进
- 部分接口和流式数据仍可能使用 mock
- 鸿蒙、macOS、Windows 暂不作为当前阶段强目标
