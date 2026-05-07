# AIDataInsight 跨平台就绪改造方案

## 文档定位

这不是一份纯理想化方案，而是基于当前仓库真实结构整理出的改造计划。

本次结论的依据包括：

- 壳工程 `AIDataInsight`
- `Packages/library-basics`
- `Packages/library-common`
- `Packages/module-ai`

其中：

- `module-ai` 已按源码实际读取
- `library-basics`、`library-common` 已读取 `Package.swift`、目录结构和关键协议/基础实现

## 当前真实现状

### 1. 壳工程很薄

壳工程里的 [AppDelegate.swift](/Users/janlor/workspace/GitHub/AIDataInsight-iOS/AIDataInsight/AIDataInsight/AppDelegate.swift:19) 和 [SceneDelegate.swift](/Users/janlor/workspace/GitHub/AIDataInsight-iOS/AIDataInsight/AIDataInsight/SceneDelegate.swift:16) 主要负责：

- 生命周期转发
- `Application.agent` 驱动模块启动
- 加载前台模块

这说明你的整体架构已经是“壳工程 + 业务包”的方向。

### 2. `library-basics` 不是纯基础库，而是“基础设施 + UIKit 基础组件 + 网络 + 路由 + 账户”

根据 [Packages/library-basics/Package.swift](/Users/janlor/workspace/GitHub/AIDataInsight-iOS/Packages/library-basics/Package.swift:1)，当前包含这些 target：

- `Account`
- `AccountProtocol`
- `AppLaunch`
- `AppSecurity`
- `BaseEnv`
- `BaseKit`
- `BaseUI`
- `BaseViewModel`
- `Environment`
- `Networking`
- `Router`
- `Storage`

这里面同时存在：

- 可继续作为跨平台基础抽象的内容：`BaseEnv`、`BaseViewModel`、`Storage` 的一部分
- 强 iOS 绑定内容：`BaseUI`、`Router`、`Account`、`AppLaunch`
- 强网络基础设施内容：`Networking`

结论：`library-basics` 需要继续拆“平台无关”和“iOS 专属”。

### 3. `library-common` 不是纯 common，而是“通用业务功能集合”

根据 [Packages/library-common/Package.swift](/Users/janlor/workspace/GitHub/AIDataInsight-iOS/Packages/library-common/Package.swift:1)，当前包含这些 target：

- `AppMain`
- `CommonViewModel`
- `Login`
- `LoginProtocol`
- `Privacy`
- `PrivacyProtocol`
- `ProtocolAI`
- `Setting`
- `SettingProtocol`

这里面混合了：

- 业务协议：`LoginProtocol`、`PrivacyProtocol`、`SettingProtocol`、`ProtocolAI`
- 业务实现：`Login`、`Privacy`、`Setting`
- 入口装配：`AppMain`
- 公共请求层：`CommonViewModel`

结论：`library-common` 当前更像“横向通用业务模块仓”，不是跨平台公共域层。

### 4. `module-ai` 当前是一个完整 UIKit 功能包，不是纯业务包

根据 [Packages/module-ai/Package.swift](/Users/janlor/workspace/GitHub/AIDataInsight-iOS/Packages/module-ai/Package.swift:1) 和实际源码，`module-ai` 包含：

- 页面控制器：`AIChatViewController`、`HistoryViewController`、`ContainerViewController`
- `ViewModel`：`AIChatViewModel`、`HistoryViewModel`
- API 定义：`ChatApi`、`ChartApi`、`HistoryApi`
- 路由：`ModuleAIRouter`
- 模块入口：`AppDelegate`
- 图表 UI：`Chart/*`
- 页面视图：`Views/*`
- 模型：`AIChat.swift`、`FunctionModel.swift`、`HistoryDetailModel.swift`、`HistoryModel.swift`

实际依赖也很明确：

- `UIKit`
- `BaseUI`
- `BaseKit`
- `Router`
- `CommonViewModel`
- `Networking`
- `DGCharts`
- `NotificationCenter`
- `DispatchQueue`

结论：`module-ai` 当前是“单包承载 UI、状态、网络、路由、部分模型”的结构，距离平台无关还有明显距离。

## 当前最关键的问题

### 1. `module-ai` 内部分层不清

`module-ai` 目前至少混了四层内容：

- 表现层：`ViewController`、Cell、BottomView、MenuViewController
- 展示状态层：`AIChatViewModel`、`HistoryViewModel`
- 数据访问层：`ChatApi`、`ChartApi`、`HistoryApi`
- 领域/模型层：`FunctionModel`、`HistoryDetailModel`、`RecordModel`

这会导致 Android/Web 迁移时无法直接映射边界。

### 2. `ViewModel` 直接依赖网络请求实现

[AIChatViewModel.swift](/Users/janlor/workspace/GitHub/AIDataInsight-iOS/Packages/module-ai/Sources/ModuleAI/AIChat/ViewModels/AIChatViewModel.swift:40) 与 [HistoryViewModel.swift](/Users/janlor/workspace/GitHub/AIDataInsight-iOS/Packages/module-ai/Sources/ModuleAI/History/ViewModels/HistoryViewModel.swift:52) 都直接调用 `CommonRequester`。

这意味着：

- `ViewModel` 不是纯展示层状态对象
- 网络层替换成本高
- Android/Web 无法直接参照“用例层”移植

### 3. 领域模型混入 UIKit 表现属性

[HistoryModel.swift](/Users/janlor/workspace/GitHub/AIDataInsight-iOS/Packages/module-ai/Sources/ModuleAI/History/HistoryModel.swift:13) 中的 `RecordModel` 和 `DetailModel` 混入了：

- `NSAttributedString`
- `UIColor`
- `UIFont`
- `NSLocalizedString`

这类内容不应该留在跨平台共享模型中。

### 4. 路由和业务意图耦合在 UIKit 行为里

[HistoryViewController.swift](/Users/janlor/workspace/GitHub/AIDataInsight-iOS/Packages/module-ai/Sources/ModuleAI/History/HistoryViewController.swift:131) 直接 `Router.present(from:to:animated:)`，当前路由模型面向 `UIViewController`，不是面向业务意图。

### 5. 异步模型仍然是 closure + `DispatchQueue`

当前真实情况：

- `BaseViewModel` 用 `CancellableTask` 管理回调任务
- `CommonRequester` 以 completion 为主
- `AIChatViewModel` 中存在 `DispatchQueue.global().async` 和 `DispatchQueue.main.async`
- SSE 通过 `onEvent` / `completion` 回调推送

这套方式可以运行，但不利于未来映射到：

- Android `suspend` / `Flow`
- Web `async` / `Promise` / stream

## 改造目标

这次改造不是先做代码共享，而是先把现有 iOS 业务组织成“可被多端复制”的结构。

目标状态：

- `module-ai` 不再是单包混合结构
- UI 层、业务层、数据层边界明确
- 平台无关逻辑不再依赖 `UIKit`
- `CommonRequester` 逐步增加 `async/await` 入口
- 页面层从“直接调网络”转成“调用 use case / repository”
- 模型层不再携带 UIKit 格式化数据

## 真实包结构下的目标演进

不要求你立刻重命名包，但建议按照下面的逻辑演进。

### `library-basics` 应拆成两类能力

保留为平台基础设施的部分：

- `BaseEnv`
- `BaseViewModel`
- `Storage` 中的平台无关部分
- `Networking` 中的协议和响应模型部分

明确归为 iOS 专属的部分：

- `BaseUI`
- `Router`
- `AppLaunch`
- `Account` 中依赖 UIKit 的能力

### `library-common` 应拆成“协议层”和“实现层”

协议层可保留：

- `LoginProtocol`
- `PrivacyProtocol`
- `SettingProtocol`
- `ProtocolAI`

实现层继续按功能存在，但要减少直接暴露 UIKit 细节：

- `Login`
- `Privacy`
- `Setting`
- `AppMain`

### `module-ai` 应在内部先拆层，再考虑拆包

建议先内部形成这几层目录：

- `Domain`
- `Data`
- `Presentation`
- `Platform`

然后再决定是否拆成多个 target。

## `module-ai` 的具体拆分建议

### 第一类：保留在表现层

这些文件先视为 iOS 表现层，不作为跨平台共享对象：

- `AIChatViewController`
- `HistoryViewController`
- `ContainerViewController`
- `Views/*`
- `Chart/*`
- `Router/ModuleAIRouter.swift`
- `AppDelegate/AppDelegate.swift`

### 第二类：需要从表现层剥离职责的文件

这些文件目前名义上是模型或 ViewModel，但实际混了多层职责：

- `AIChat/ViewModels/AIChatViewModel.swift`
- `History/ViewModels/HistoryViewModel.swift`
- `History/HistoryModel.swift`
- `AIChat/Models/AIChatRichText.swift`

### 第三类：可演进为领域/数据基础的文件

这些文件最适合优先改造成平台无关结构：

- `AIChat/Models/FunctionModel.swift`
- `AIChat/Models/HistoryDetailModel.swift`
- `AIChat/Models/TemplateModel.swift`
- `AIChat/Models/AIChat.swift`
- `Api/ChatApi.swift`
- `Api/ChartApi.swift`
- `Api/HistoryApi.swift`

但要注意：它们现在还不是纯领域层，仍有 `Networking`、`BaseKit`、UIKit 间接耦合，需要继续拆。

## 一步一步执行方案

以下顺序按“跨平台收益最高、风险最低”排列。

### 第 0 步：同步包的最低平台版本

你已经把壳工程提到 `iOS 15+`，但三个包的 `Package.swift` 仍然写的是 `.iOS(.v13)`。

需要同步检查并升级：

- [Packages/library-basics/Package.swift](/Users/janlor/workspace/GitHub/AIDataInsight-iOS/Packages/library-basics/Package.swift:8)
- [Packages/library-common/Package.swift](/Users/janlor/workspace/GitHub/AIDataInsight-iOS/Packages/library-common/Package.swift:8)
- [Packages/module-ai/Package.swift](/Users/janlor/workspace/GitHub/AIDataInsight-iOS/Packages/module-ai/Package.swift:8)

否则工程最低版本和包最低版本不一致。

### 第 1 步：先在 `module-ai` 内做逻辑分层，不急着拆包

先在 `Sources/ModuleAI` 下形成这样的结构：

- `Domain/Entities`
- `Domain/UseCases`
- `Domain/Protocols`
- `Data/APIs`
- `Data/Repositories`
- `Data/Mappers`
- `Presentation/AIChat`
- `Presentation/History`
- `Platform/iOS`

第一阶段只是搬目录和梳理依赖，不要求你一次完成全部接口重写。

### 第 2 步：把 `ViewModel` 里的网络逻辑抽成 Repository

当前直接依赖 `CommonRequester` 的逻辑，应先抽接口。

建议先定义：

```swift
protocol AIChatRepository {
    func loadTemplate() async throws -> TemplateModel
    func sendFunctionMessage(_ text: String, historyId: Int?) async throws -> FunctionModel
    func loadHistoryDetail(_ historyId: Int) async throws -> RecordModel
    func loadChartData(name: FunctionName, historyId: Int, arguments: any DictionaryConvertible) async throws -> HistoryDetailModel
    func sendLikeFeedback(historyDetailId: Int, like: String) async throws
    func streamMessage(_ text: String) -> AsyncThrowingStream<String, Error>
}

protocol AIHistoryRepository {
    func loadPage(pageNo: Int, pageSize: Int) async throws -> RecordPageModel
    func deleteHistory(historyId: Int) async throws
    func deleteAllHistory() async throws
}
```

然后：

- `AIChatViewModel` 不再直接碰 `ChatApi` / `ChartApi` / `HistoryApi`
- `HistoryViewModel` 不再直接碰 `HistoryApi`

### 第 3 步：先做 async bridge，不要一口气删旧 callback

现阶段最合适的切入点不是重写 `Networking`，而是在 `CommonRequester` 上加 async 封装。

建议优先新增：

```swift
extension CommonRequester {
    static func requestNet<T: Codable>(_ target: RequestDescriptor) async throws -> T
    static func requestVoid(_ target: RequestDescriptor) async throws
    static func requestSSE(_ request: URLRequest) -> AsyncThrowingStream<String, Error>
}
```

实现方式用 `withCheckedThrowingContinuation` 和 `AsyncThrowingStream` 即可。

这样收益最大：

- 保留现有网络基础设施
- 页面可以渐进迁移
- Android/Web 可以开始以 async 风格建模

### 第 4 步：把 `AIChatViewModel` 改成 async 驱动

当前 `AIChatViewModel` 的职责过多，建议拆成：

- `AIChatViewModel`
  - 只负责页面状态
- `LoadTemplateUseCase`
- `SendFunctionMessageUseCase`
- `LoadChartDataUseCase`
- `LoadHistoryDetailUseCase`
- `SendLikeFeedbackUseCase`
- `StreamAIMessageUseCase`

第一阶段也可以不引入完整 use case 类型，先让 `ViewModel` 依赖 repository。

最低改造目标：

- 输入接口改成 async 方法
- SSE 改成 `AsyncThrowingStream`
- 删除手动 `DispatchQueue.main.async` 分发
- 在 UI 层使用 `Task {}` 和 `@MainActor` 消费结果

### 第 5 步：把 `HistoryViewModel` 改成 async 驱动

[HistoryViewModel.swift](/Users/janlor/workspace/GitHub/AIDataInsight-iOS/Packages/module-ai/Sources/ModuleAI/History/ViewModels/HistoryViewModel.swift:22) 当前已有较清晰的分页和分组逻辑，适合作为第二个迁移点。

建议顺序：

1. `page` 接口改 async
2. `delete` / `deleteAll` 改 async
3. 日期分组逻辑从 `ViewModel` 或 `RecordModel` 中抽成纯函数
4. `onDataLoaded` / `onDataLoadFailed` 最终收敛为状态更新

### 第 6 步：把“领域数据”和“显示数据”分开

当前最需要拆的典型文件是 [HistoryModel.swift](/Users/janlor/workspace/GitHub/AIDataInsight-iOS/Packages/module-ai/Sources/ModuleAI/History/HistoryModel.swift:1)。

建议改成两类模型：

- 领域模型
  - `Record`
  - `RecordDetail`
  - `HistoryDetail`
- 展示模型
  - `HistoryListItemViewData`
  - `HistorySectionViewData`
  - `AIChatMessageViewData`

不要再让领域模型里带：

- `NSAttributedString`
- `UIColor`
- `UIFont`
- 本地化文案拼接结果

### 第 7 步：把意图判断和图表数据转换从 ViewModel 中抽出

`AIChatViewModel` 里两类逻辑其实是纯业务规则，应该抽出来：

- 函数调用返回后的意图判断
- `HistoryDetailModel -> [AIBarChartData]` 的图表转换

建议形成：

- `AIIntentResolver`
- `ChartDataBuilder`

然后再区分两层：

- 领域层输出：统一图表语义模型
- iOS 表现层输出：`AIBarChartData`

否则未来 Android/Web 还得重新反推你当前 iOS 图表规则。

### 第 8 步：把 Router 从 UIKit 跳转改成业务意图

当前：

- `Router.target(to:)`
- `Router.present(from:to:animated:)`
- `Router.push(from:to:animated:)`

都是 `UIViewController` 导向。

对跨平台更好的做法是让业务层输出意图，例如：

```swift
enum AIRouteIntent: Equatable {
    case openHistory
    case openSetting
    case openConversation(historyId: Int?)
}
```

UIKit 层再把意图翻译成：

- push
- present
- 切换容器状态

第一阶段不需要推翻现有 Router，只需要让 `module-ai` 业务流程尽量不要直接知道 UIViewController。

### 第 9 步：把通知和共享单例逐步收口

当前真实使用里有：

- `NotificationCenter.default`
- `NetworkMonitor.shared`
- `Application.agent`
- `Router.handler`

这些并不一定马上删，但要限制它们只出现在：

- app shell
- platform adapter
- iOS presentation glue

不要继续向领域层扩散。

## async/await 改造优先级

按你当前真实代码，建议这样排：

### 第一优先级

- `CommonRequester.requestNet`
- `CommonRequester.requestVoid`
- `CommonRequester.requestSSE`

### 第二优先级

- `AIChatViewModel`
- `HistoryViewModel`

### 第三优先级

- `LoginProtocol` 的 `refresh` / `logout`
- `AccountProtocol` 里所有 completion 风格的网络方法

### 第四优先级

- `Networking` 内部 token refresh 链路
- `NetworkMonitor` 观察模型

## 当前阶段不要做的事

先不要做这些：

- 全量 UIKit -> SwiftUI 重写
- 直接切 Swift 6 language mode
- 先做 Android/Web UI
- 用 C++ 重写业务层
- 一开始就把所有包重新命名

这些都会让复杂度失控。

## 本轮改造完成后的“跨平台就绪”标准

达到下面几个条件，就算准备好了：

- `module-ai` 的网络访问不再直接写在 `ViewModel`
- AI/History 的核心流程已有 repository 抽象
- SSE 已能通过 `AsyncThrowingStream` 使用
- 领域模型不再依赖 UIKit 格式化对象
- 路由开始从 UIViewController 导向转为业务意图导向
- `library-basics` / `library-common` 中的平台相关边界已明确

到这一步，AI 才能更稳定地帮你平移到：

- Android：Kotlin + Compose + suspend/Flow
- Web：TypeScript + Next.js + async/query hooks

## 下一步建议

最合理的后续动作是：

1. 先把三个 `Package.swift` 的平台版本同步到 `iOS 15+`
2. 先给 `CommonRequester` 增加 async bridge
3. 以 `HistoryViewModel` 为第一个样板做 async 迁移
4. 再处理 `AIChatViewModel`
5. 最后再开始模块拆层

如果你要我继续做，下一步最有价值的是直接基于真实代码继续产出：

- `module-ai` 文件级现状审计表
- `CommonRequester` 的 async/await 改造设计
- `HistoryViewModel` 的第一版重构方案
