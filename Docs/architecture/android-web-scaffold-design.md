# AIDataInsight Android / Web 架构脚手架设计

## 文档目的

这份文档用于指导你开始 Android 和 Web 的第一阶段学习与搭建。

它不讨论上线节奏，也不追求三端代码共享。

它只回答四件事：

- Android 和 Web 第一版项目结构应该怎么搭
- 当前 iOS 模块怎么映射到 Android / Web
- 第一阶段先做哪些功能
- 哪些规则三端应该共用，哪些必须各端独立实现

## 当前前提

这份设计文档建立在你当前 iOS 仓库已经完成的第一阶段重构之上：

- `module-ai` 已有 `Domain / Repositories / Presentation / Views`
- `library-common` 的 `Login / Setting / Privacy` 已完成第一轮分层
- `library-basics` 的 `Networking / Account` 已开始解耦
- 当前代码已经有最小测试保护

因此，Android / Web 不应该从“页面长什么样”开始学，而应该从“模块和职责怎么对应”开始学。

## 总体策略

### 不做三端 UI 共享

当前阶段不建议做：

- Kotlin Multiplatform UI 共享
- Compose Multiplatform + Web 共用 UI
- Swift 代码转 C++ 或其他共享语言

原因很简单：

- 你的目标是借助 AI 学习多端架构
- 你现在最有价值的是学清楚边界和职责
- UI 共享会放大框架差异和调试成本

当前最合理的路径是：

- 共享架构思想
- 共享领域模型定义
- 共享 API 契约
- 共享业务规则
- 不共享 UI 实现

## 推荐技术栈

### Android

建议第一阶段使用：

- Kotlin
- Jetpack Compose
- Navigation Compose
- ViewModel
- Coroutines
- Flow
- Kotlin Serialization
- Ktor Client 或 Retrofit

### Web

建议第一阶段使用：

- TypeScript
- Next.js App Router
- React
- Server Components + Client Components 混合
- TanStack Query
- Zod

### 为什么这样选

因为它们和你当前 iOS 的分层最容易形成稳定映射：

- Swift async/await -> Kotlin Coroutines -> JS async/await
- iOS ViewModel -> Android ViewModel -> Web page state / hooks
- Repository 模式三端都能成立

## Android 项目脚手架

建议单独建仓，或者在 monorepo 中新建：

```text
apps/android/
  app/
  core/
    common/
    model/
    network/
    account/
    testing/
  feature/
    login/
    setting/
    privacy/
    ai-chat/
    history/
```

### 推荐职责

`app/`

- 应用入口
- NavHost
- DI 装配
- 全局主题

`core/common/`

- 通用工具
- Result / Error 类型
- 时间、格式化、日志等基础能力

`core/model/`

- 纯领域模型
- DTO 到 domain 之后的稳定结构

`core/network/`

- HTTP client
- auth header provider
- token refresh coordinator
- session invalidation handler

`core/account/`

- session store
- user store
- account remote service

`feature/login/`

- login domain
- login repository
- login presentation
- login compose ui

`feature/setting/`

- setting snapshot
- setting repository
- setting viewmodel
- setting screen

`feature/privacy/`

- privacy repository
- privacy dialog state
- privacy web page route

`feature/ai-chat/`

- ai chat repository
- intent resolver
- chart builder
- chat viewmodel
- screen

`feature/history/`

- history repository
- history list builder
- history viewmodel
- screen

## Web 项目脚手架

建议单独建仓，或者在 monorepo 中新建：

```text
apps/web/
  app/
    (auth)/
    (main)/
    api/
  src/
    domain/
    data/
    features/
      login/
      setting/
      privacy/
      ai-chat/
      history/
    components/
    lib/
    state/
    testing/
```

### 推荐职责

`app/`

- Next.js 路由入口
- layout
- 页面级 server/client 组合

`src/domain/`

- 纯领域模型
- 领域错误
- 领域枚举

`src/data/`

- API client
- DTO
- repository 实现
- token refresh
- session invalidation

`src/features/login/`

- login repository interface
- login action / hook
- login form state
- login page/ui

`src/features/setting/`

- setting snapshot
- setting mapper
- setting screen state
- setting page/ui

`src/features/privacy/`

- privacy agreement state
- privacy dialog model
- privacy page/ui

`src/features/ai-chat/`

- function result model
- intent resolver
- chart data transform
- chat state
- page/ui

`src/features/history/`

- grouped history builder
- history page state
- page/ui

`src/components/`

- 通用 UI 组件

`src/lib/`

- fetch wrapper
- auth storage
- date formatter
- browser adapters

## 当前 iOS 到 Android / Web 的映射表

### 1. `library-basics`

#### iOS: `Networking`

对应 Android：

- `core/network/http`
- `core/network/auth`
- `core/network/session`

对应 Web：

- `src/data/http`
- `src/data/auth`
- `src/data/session`

映射原则：

- `NetworkCredentialProvider` -> token provider
- `TokenRefreshService` -> refresh coordinator
- `SessionInvalidationHandler` -> logout/reset handler

#### iOS: `AccountProtocol`

对应 Android：

- `core/account/session`
- `core/account/user`
- `core/account/remote`
- `core/account/navigation-adapter`

对应 Web：

- `src/data/account/session`
- `src/data/account/user`
- `src/data/account/remote`
- `src/features/account/route-adapter`

映射原则：

- `AccountSessionStore` 单独映射
- `AccountUserStore` 单独映射
- `AccountRemoteService` 单独映射
- `AccountRouteService` 不共享，只做平台适配

### 2. `library-common`

#### iOS: `Login`

对应 Android：

- `feature/login/domain`
- `feature/login/data`
- `feature/login/presentation`

对应 Web：

- `src/features/login/domain`
- `src/features/login/data`
- `src/features/login/presentation`

映射原则：

- `LoginRepository` 继续保留
- 登录成功后只操作 session store

#### iOS: `Setting`

对应 Android：

- `feature/setting/domain`
- `feature/setting/data`
- `feature/setting/presentation`

对应 Web：

- `src/features/setting/domain`
- `src/features/setting/data`
- `src/features/setting/presentation`

映射原则：

- `SettingSnapshot` 是非常好的三端共享概念
- `SettingViewData` 各端独立实现

#### iOS: `Privacy`

对应 Android：

- `feature/privacy/domain`
- `feature/privacy/data`
- `feature/privacy/presentation`

对应 Web：

- `src/features/privacy/domain`
- `src/features/privacy/data`
- `src/features/privacy/presentation`

映射原则：

- 是否需要弹协议
- 协议版本是否已同意
- 弹窗内容模型

这些规则三端都一致。

### 3. `module-ai`

#### iOS: `Domain`

对应 Android：

- `feature/ai-chat/domain`
- `feature/history/domain`

对应 Web：

- `src/features/ai-chat/domain`
- `src/features/history/domain`

映射原则：

- 保持模型语义一致
- 不复制 UIKit / NSAttributedString / UIColor 概念

#### iOS: `Repositories`

对应 Android：

- `feature/ai-chat/data`
- `feature/history/data`

对应 Web：

- `src/features/ai-chat/data`
- `src/features/history/data`

映射原则：

- repository 名字尽量一致
- DTO 与 domain 转换逻辑在 data 层

#### iOS: `Presentation`

对应 Android：

- `feature/ai-chat/presentation`
- `feature/history/presentation`

对应 Web：

- `src/features/ai-chat/presentation`
- `src/features/history/presentation`

映射原则：

- `AIChatIntentResolver`
- `AIChatChartBuilder`
- `AIChatHistoryMapper`
- `HistoryListViewDataBuilder`

这些结构和职责建议直接镜像。

#### iOS: `Views`

对应 Android：

- Compose Screen / components

对应 Web：

- React components / page sections

映射原则：

- 完全独立实现
- 不追求 UI 一比一
- 只保持信息结构和状态一致

## 第一阶段先做哪些页面

### 建议顺序

1. 登录
2. 设置
3. 历史列表
4. AI 聊天首页
5. 历史详情回放

### 为什么这样排

因为它和你当前 iOS 改造顺序一致：

- 登录最容易建立 session / refresh / logout 概念
- 设置最容易验证账户、隐私、会话边界
- 历史最容易验证 repository + view data builder
- AI 聊天最复杂，放后面更稳

## 三端共用的规则

这些东西三端应该尽量保持一致。

### 1. API 契约

- URL 路径
- 请求参数
- 响应模型
- 错误码
- token refresh 规则

### 2. 领域模型

- 账户信息
- 设置快照
- 历史记录
- 聊天消息
- 函数调用参数

### 3. 业务规则

- 登录成功后的会话处理
- token 失效处理
- 隐私协议是否需要弹出
- 历史记录如何分组
- AI 函数意图如何识别

### 4. 状态命名

建议三端尽量统一这些命名：

- `Repository`
- `Snapshot`
- `ViewData`
- `IntentResolver`
- `ChartBuilder`
- `SessionStore`

这样 AI 后续帮你跨端迁移时会稳定很多。

## 三端不共用的部分

这些东西必须接受各端独立实现。

### 1. UI 组件

- UIKit
- Compose
- React

### 2. 路由

- iOS `Router`
- Android Navigation
- Web URL route

### 3. 平台能力

- Keychain / Android Keystore / browser storage
- App lifecycle / Activity lifecycle / browser lifecycle
- 推送、剪贴板、分享、相册、文件选择

### 4. 富文本和图表渲染

- iOS `NSAttributedString`
- Android `AnnotatedString` / text styling
- Web JSX / HTML fragments

应共享“数据和意图”，不共享“渲染对象”。

## 第一阶段仓库建议

如果你暂时不想动现有仓库结构，可以先只写文档和目录草案。

如果你准备正式开始多端学习，我建议最终演进成：

```text
AIDataInsight/
  apps/
    ios/
    android/
    web/
  packages/
    api-spec/
    docs/
```

但现阶段不必强行搬仓。

你可以先保持现在的 iOS 仓库不动，然后：

- 新建 `AIDataInsight-Android`
- 新建 `AIDataInsight-Web`

先各自按本文档搭脚手架。

## Android 第一阶段脚手架建议

第一阶段只搭这些内容就够了：

- app 入口
- session store
- network client
- login feature
- setting feature
- history feature

不要第一阶段就做：

- 复杂图表编辑
- 完整 SSE 聊天流
- 多主题皮肤
- 大量动画

## Web 第一阶段脚手架建议

第一阶段只搭这些内容就够了：

- app router
- auth/session
- login page
- setting page
- history page
- chat page 的静态状态骨架

不要第一阶段就做：

- 复杂 SSR/ISR 优化
- 大量 SEO 页面
- 图表高级交互

## 对你个人学习最重要的点

你现在不是在学某个端的语法，而是在学“如何让 AI 帮你维护多端一致结构”。

所以你后面给 AI 的输入，最好始终围绕这些对象：

- repository
- snapshot
- view data
- session store
- route adapter
- DTO -> domain mapper

这会比单纯说“帮我写一个登录页”有价值得多。

## 下一步建议

如果你准备正式进入 Android / Web 学习阶段，建议按这个顺序继续：

1. 先为 Android 写一份目录初始化文档
2. 再为 Web 写一份目录初始化文档
3. 再做 iOS -> Android 模块映射表
4. 最后开始生成第一个端的真实代码

## 一句话结论

你现在的 iOS 代码已经足够作为 Android / Web 的结构母版。

下一步不是继续深挖 iOS，而是按照当前已经整理出的：

- `Domain`
- `Repository`
- `Presentation`
- `Platform Adapter`

思路，正式开始 Android 和 Web 的镜像脚手架设计与实现。
