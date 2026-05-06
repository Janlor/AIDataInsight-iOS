# AIDataInsight 跨平台蓝图

## 目标

这份蓝图回答的是：

- 在你当前真实包结构上，未来 Android 和 Web 应该如何映射
- iOS 代码应该先演进到什么形态
- 哪些东西共享“规则”，哪些东西各端独立实现

这份文档不要求你马上共享代码，而是要求你先共享架构语言。

## 设计原则

你的目标不是“一个人写三套完全不同的程序”，而是“一个人维护一套稳定的业务模型，让 AI 去帮助生成三端实现”。

所以真正应该共享的是：

- 领域模型
- API 契约
- 业务用例
- 错误模型
- 路由意图
- 设计 token

不应该一开始强求共享的是：

- UIKit 页面代码
- Android Compose 页面代码
- Web React 页面代码

## 基于当前仓库的目标分层

建议最终把项目理解成四层。

### 1. App Shell

负责：

- 生命周期
- 启动装配
- 模块注册
- 平台入口

当前对应：

- `AIDataInsight` 壳工程
- `library-basics/AppLaunch`
- `module-ai/AppDelegate`

### 2. Platform Layer

负责：

- iOS Router
- 通知
- 权限
- 相册/相机
- Keychain
- 外部链接

当前对应：

- `library-basics/Router`
- `library-basics/Account`
- `library-basics/BaseUI`
- `module-ai/Router`

### 3. Application Layer

负责：

- ViewModel
- 页面状态
- 用例调度
- 业务流程编排

当前对应：

- `module-ai/AIChat/ViewModels`
- `module-ai/History/ViewModels`
- `library-common/CommonViewModel`

### 4. Domain + Data Layer

负责：

- 领域模型
- 仓储协议
- API DTO
- repository 实现
- 业务规则
- 数据映射

当前对应：

- `module-ai/Api`
- `module-ai/AIChat/Models`
- `module-ai/History/HistoryModel`
- `library-basics/Networking`

## 三个包未来应该怎么演进

## `library-basics`

未来角色：

- iOS 基础设施层
- 不是跨平台公共域层

建议保留方向：

- `AppLaunch`
- `AppSecurity`
- `BaseEnv`
- `BaseViewModel`
- `Networking`
- `Storage`

建议明确标记为 iOS 专属：

- `BaseUI`
- `Router`
- `Account`

建议后续演进：

- `Networking` 增加 async/await API
- `Router` 保留现有 UIKit 版本，但上层改为路由意图
- `BaseViewModel` 从 callback task 管理，逐步兼容 Swift Concurrency task 管理

## `library-common`

未来角色：

- 横向公共业务协议层
- 少量共享业务实现

建议保留协议：

- `LoginProtocol`
- `PrivacyProtocol`
- `SettingProtocol`
- `ProtocolAI`

建议谨慎对待的实现：

- `Login`
- `Privacy`
- `Setting`
- `AppMain`

建议后续演进：

- 协议层尽量去掉 UIKit 入参
- 公共请求辅助不再直接面向页面 closure 风格
- `CommonRequester` 逐步从“页面请求工具”升级为“数据访问桥接层”

## `module-ai`

未来角色：

- AI 功能域
- 优先在包内完成分层，再考虑拆成多个 target

建议包内目标结构：

- `Domain`
- `Data`
- `Presentation`
- `Platform`

建议迁移顺序：

1. 先抽 repository
2. 再抽 use case
3. 再拆模型
4. 最后再考虑拆 target

## 三端映射关系

### iOS

- 表现层：UIKit，后续可局部引入 SwiftUI
- 状态层：`ViewModel + async/await`
- 数据层：repository + `Networking`
- 流式输出：`AsyncThrowingStream`

### Android

- 表现层：Jetpack Compose
- 状态层：`ViewModel + StateFlow`
- 数据层：repository + Retrofit/Ktor
- 流式输出：`Flow`

### Web

- 表现层：Next.js App Router + React + TypeScript
- 状态层：server/client action + query hooks
- 数据层：service/repository
- 流式输出：`ReadableStream` 或封装后的 async iterator

## 多端统一契约应该长什么样

建议你最终维护 5 类核心契约。

### 1. 领域实体

例如：

- `Insight`
- `InsightDetail`
- `HistoryRecord`
- `HistoryMessage`
- `ChartSeries`
- `ChartPoint`

### 2. 请求模型

例如：

- `LoadHistoryPageRequest`
- `SendAIQuestionRequest`
- `LoadChartDataRequest`
- `SendFeedbackRequest`

### 3. 仓储协议

例如：

- `AIChatRepository`
- `HistoryRepository`
- `SessionRepository`
- `SettingsRepository`

### 4. 用例

例如：

- `SendAIQuestionUseCase`
- `LoadHistoryUseCase`
- `DeleteHistoryUseCase`
- `StreamAIResponseUseCase`

### 5. 路由意图

例如：

```swift
enum AppRouteIntent {
    case openAIHome
    case openHistory(historyId: Int?)
    case openSettings
    case back
}
```

## 为什么不建议现在就共享代码

原因不是做不到，而是不划算。

你当前的问题是：

- iOS 代码边界还没稳定
- 业务模型和显示模型还混着
- 异步模型还没统一
- 路由还耦合 UIKit

这时如果强行上共享实现，只会把不稳定结构复制到别的平台。

更好的节奏是：

1. 先在 iOS 把边界做对
2. 再用同一份契约让 AI 帮你生成 Android/Web
3. 如果后面发现确实有大量可共享规则，再考虑 KMP 等方案

## 推荐技术落点

### Android

- Kotlin
- Jetpack Compose
- Navigation Compose
- ViewModel
- Coroutines
- Flow

### Web

- Next.js App Router
- React
- TypeScript
- TanStack Query
- ECharts 或 AntV

### iOS

- UIKit 继续保留
- 先做 async/await 和平台无关化
- SwiftUI 只做增量接入，不做一次性重写

## 第一阶段里程碑

### 里程碑 1：iOS 架构整理

完成标准：

- `CommonRequester` 有 async bridge
- `HistoryViewModel` 改造完成
- `AIChatViewModel` 去掉直接请求逻辑
- 历史与聊天核心模型完成“领域/显示”拆分

### 里程碑 2：契约冻结

完成标准：

- API 契约稳定
- 领域模型稳定
- 仓储协议稳定
- 路由意图稳定

### 里程碑 3：Android/Web 启动

完成标准：

- Android 可以按同一仓储协议实现数据层
- Web 可以按同一实体和请求模型实现服务层
- AI 可以根据同一文档稳定生成三端代码

## 你现在最值得做的事

不是立刻新建 Android 或 Web 仓库，而是按下面顺序推进：

1. 同步三个包的最低版本到 `iOS 15+`
2. 给 `CommonRequester` 增加 async/await
3. 先重构 `HistoryViewModel`
4. 再重构 `AIChatViewModel`
5. 把 `module-ai` 内部按层整理
6. 冻结领域契约
7. 再开始 Android/Web

## 结论

对你这个项目，真正的跨平台蓝图不是“现在就共享三端代码”，而是：

- iOS 先成为清晰的参考实现
- 业务边界先稳定
- 异步模型先统一
- 契约先沉淀
- 然后让 AI 基于这套契约生成 Android 和 Web

这是最适合“一人 + AI + 多端学习”的路线。
