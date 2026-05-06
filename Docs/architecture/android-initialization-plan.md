# AIDataInsight-Android 目录初始化方案

## 文档目的

这份文档只解决一件事：

如果你现在开始新建 `AIDataInsight-Android`，第一版目录和模块应该怎么搭。

它面向的是“先把结构搭对”，不是“先把页面写出来”。

## 目标

第一阶段要达成的不是 Android 功能完整，而是：

- 建立和当前 iOS 一致的分层语言
- 让 AI 后续能稳定生成代码
- 让登录、设置、历史、聊天这些 feature 有固定落点

## 技术基线

建议第一版直接定成：

- Kotlin
- Jetpack Compose
- Navigation Compose
- AndroidX ViewModel
- Kotlin Coroutines
- Flow
- Kotlin Serialization
- Ktor Client
- Gradle Kotlin DSL

不建议第一版就引入：

- 复杂多模块插件体系
- 过重的 DI 框架魔法
- 过多代码生成

先把结构跑通，比追求“行业最标准模板”更重要。

## 第一版仓库结构

建议新建仓库后直接搭成这样：

```text
AIDataInsight-Android/
  app/
  core/
    common/
    model/
    network/
    account/
    ui/
    testing/
  feature/
    login/
    setting/
    privacy/
    history/
    ai-chat/
  gradle/
  build.gradle.kts
  settings.gradle.kts
```

## 每个目录放什么

### `app/`

只放应用级装配：

- `Application`
- `MainActivity`
- `NavHost`
- 全局 theme
- 顶层依赖组装

不要把业务逻辑塞进 `app/`。

### `core/common/`

放所有 feature 都会依赖，但不属于某个业务域的东西：

- `AppResult`
- `AppError`
- 时间工具
- 字符串/数字格式化
- 通用扩展
- dispatcher provider

对应你当前 iOS 的：

- `BaseViewModel`
- 一部分 `BaseKit`
- 一部分 `BaseEnv`

### `core/model/`

放稳定的领域模型：

- `AccountSession`
- `SettingSnapshot`
- `HistoryRecord`
- `HistoryDetail`
- `FunctionModel`
- `FunctionArguments`

原则：

- 这里只放 domain model
- 不放 API DTO
- 不放 Compose UI model

### `core/network/`

放网络基础设施：

- `ApiClient`
- `NetworkCredentialProvider`
- `TokenRefreshService`
- `SessionInvalidationHandler`
- `ApiResponse`
- `NetworkError`

这块直接对应你现在 iOS 里已经抽出来的：

- `NetworkDependencies`
- `NetworkCredentialProvider`
- `TokenRefreshService`
- `SessionInvalidationHandler`

### `core/account/`

放账户与会话边界：

- `AccountSessionStore`
- `AccountUserStore`
- `AccountRemoteService`
- 本地 session storage
- 用户信息缓存

这块直接镜像你现在 iOS 的 `AccountProtocol` 子协议拆分结果。

### `core/ui/`

只放 Android 通用 UI 能力：

- theme
- typography
- spacing
- 公共 Compose 组件

不要把 feature 特有组件放进来。

### `core/testing/`

放测试公共能力：

- fake repository
- test dispatcher
- fixture builder

## feature 模块初始化建议

### `feature/login/`

建议第一版结构：

```text
feature/login/
  src/main/java/.../login/
    domain/
    data/
    presentation/
    ui/
```

职责如下：

- `domain/`
  - `LoginRepository`
- `data/`
  - `DefaultLoginRepository`
  - `LoginRequestDto`
  - `LoginResponseDto`
- `presentation/`
  - `LoginViewModel`
  - `LoginUiState`
- `ui/`
  - `LoginScreen`
  - `LoginRoute`

### `feature/setting/`

```text
feature/setting/
  src/main/java/.../setting/
    domain/
    data/
    presentation/
    ui/
```

建议最先落的对象：

- `SettingSnapshot`
- `SettingCapability`
- `SettingRepository`
- `SettingViewModel`
- `SettingUiState`

对应你现在 iOS 的 `SettingSnapshot -> ViewData` 这条链。

### `feature/privacy/`

建议最先落：

- `PrivacyRepository`
- `PrivacyPolicyViewModel`
- `PrivacyDialogState`
- `PrivacyWebScreen`

不要一开始就纠结 WebView 包装细节，先把“该不该弹”和“同意后怎么存”做对。

### `feature/history/`

建议最先落：

- `HistoryRepository`
- `HistoryViewModel`
- `HistorySectionUiModel`
- `HistoryListBuilder`
- `HistoryScreen`

这块要严格镜像你 iOS 当前的 `HistoryListViewDataBuilder` 思路。

### `feature/ai-chat/`

建议最先落：

- `AIChatRepository`
- `AIChatViewModel`
- `AIChatIntentResolver`
- `AIChatChartBuilder`
- `AIChatHistoryMapper`

第一阶段先不要做完整 SSE 聊天体验，只先把：

- 模板加载
- 历史回放
- 函数意图识别
- 图表数据转换

这些结构搭起来。

## Gradle 模块建议

如果你愿意一开始就做模块化，推荐：

```text
:app
:core:common
:core:model
:core:network
:core:account
:core:ui
:core:testing
:feature:login
:feature:setting
:feature:privacy
:feature:history
:feature:ai-chat
```

如果你想先降低复杂度，也可以先退一步：

```text
:app
:core
:feature:login
:feature:setting
:feature:privacy
:feature:history
:feature:ai-chat
```

建议你个人学习第一阶段用第二种，更轻。

## 推荐初始化顺序

### 第 1 天

完成这些就够：

- 新建 Android 项目
- 切到 Kotlin DSL
- 建 `app + core + feature` 基础目录
- 接入 Compose
- 配好 Navigation Compose
- 建一个空的 `AppNavHost`

### 第 2 天

完成：

- `core/network`
- `core/account`
- `LoginRepository`
- `LoginViewModel`
- `LoginScreen`

### 第 3 天

完成：

- `SettingSnapshot`
- `SettingRepository`
- `SettingViewModel`
- `SettingScreen`

### 第 4 天

完成：

- `HistoryRepository`
- `HistoryViewModel`
- `HistoryListBuilder`
- `HistoryScreen`

### 第 5 天以后

再进入：

- `AIChatRepository`
- `AIChatIntentResolver`
- `AIChatChartBuilder`
- `AIChatScreen`

## 与当前 iOS 的强映射规则

Android 这边请尽量保留这些名字：

- `Repository`
- `Snapshot`
- `ViewModel`
- `IntentResolver`
- `ChartBuilder`
- `HistoryMapper`
- `SessionStore`

这样做的原因不是形式统一，而是：

- 你当前 iOS 已经形成这套语言
- 后面让 AI 帮你从 iOS 翻译到 Android 时，成功率会高很多

## 第一版不做什么

为了避免把学习目标打散，第一版明确不做这些：

- 不先做复杂图表组件封装
- 不先做分页下拉刷新完整体验
- 不先做深色模式适配
- 不先做埋点系统
- 不先做完整离线缓存体系
- 不先做复杂依赖注入框架

先把结构跑起来。

## 最小可运行目标

Android 第一阶段最小可运行版本应该满足：

1. 能打开 App
2. 能显示登录页
3. 登录成功后能切到主区
4. 能打开设置页
5. 能显示历史页静态列表
6. 能进入 AI 聊天页骨架

到这里，你就已经完成“镜像 iOS 当前结构”的第一步了。

## 你后续给 AI 的任务模板

后面你让 AI 帮你做 Android，建议多用这种表达：

- “按 iOS 现有 `SettingSnapshot -> ViewData` 结构，生成 Android 的 `SettingUiState` 和 `SettingViewModel`”
- “参考 iOS 的 `HistoryListViewDataBuilder`，写 Android 的 `HistorySectionUiModel` builder”
- “参考 iOS 的 `NetworkDependencies`，搭 Android 的 token refresh coordinator”

少用这种表达：

- “帮我写个 Android 设置页”
- “帮我做个 Android 聊天页面”

前者更容易保持多端一致。

## 下一步建议

如果继续，我建议下一个文档直接写：

- `web-initialization-plan.md`

或者更实用一点，直接写：

- `android-module-mapping-checklist.md`

把当前 iOS 的每个关键对象逐项映射到 Android。

## 一句话结论

`AIDataInsight-Android` 第一阶段应该先学会“按 iOS 现有分层镜像搭结构”，而不是先学会“写多少 Compose 页面”。
