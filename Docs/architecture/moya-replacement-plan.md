# AIDataInsight Moya 替换方案

## 文档目的

这份文档用于指导当前 iOS 工程从 `Moya` 迁移到新的网络层实现。

它不是“立刻重写 Networking”的任务单，而是一份可分阶段执行的替换方案。

目标有三个：

- 降低对 `Moya` 的长期依赖
- 保持当前已完成的分层成果不被破坏
- 为 Android / Web 的网络层镜像提供更稳定的参考母版

## 为什么现在适合开始设计替换

不是所有时点都适合替换网络库。

你现在适合开始设计，原因是：

- `Networking` 已经从 `Router + AccountProtocol` 直接耦合中抽出一层
- `NetworkDependencies` 已经建立
- `module-ai`、`library-common` 的业务层大多不再直接依赖 `Moya`
- `Repository / ViewModel / Mapper` 的边界已经开始稳定

也就是说：

现在替换 `Moya`，影响的是“网络基础设施层”，而不是所有业务页面。

## 当前网络层真实情况

基于当前仓库，`Networking` 里还保留这些 `Moya` 绑定：

- `CustomTargetType: Moya.TargetType`
- `CustomMultiTarget`
- `Endpoint`
- `PluginType`
- `MoyaProvider`
- `NetworkError` 中部分错误来源
- `NetworkAuthPlugin`
- `customEndpointMapping`

另外：

- `ResponseModel<T>` 已经是你自己的响应壳
- `NetworkDependencies` 已经是你自己的会话依赖抽象
- `CustomTargetType` 已经承担了“请求描述对象”的角色

这说明当前最适合的替换方向不是“换个新的大封装库”，而是：

- 保留你自己的请求描述层
- 把底层执行从 `MoyaProvider` 改成 `URLSession`

## 结论：推荐替换方向

### 推荐方案

**推荐用 `URLSession + 轻量自研执行层` 替换 `Moya`。**

不建议从 `Moya` 换到另一个重封装库再适配一层。

### 原因

#### 1. `URLSession` 是系统原生长期能力

Apple 官方已经提供了适合你当前结构的 async API：

- `URLSession.data(for:)`
- `URLSession.bytes(for:delegate:)`
- `URLSession.AsyncBytes`

这三项已经覆盖你现在最关心的两类能力：

- 普通请求
- 流式字节读取

来源：

- Apple `URLSession.data(for:)`
- Apple `URLSession.bytes(for:delegate:)`
- Apple `URLSession.AsyncBytes`

#### 2. 你当前工程并不依赖 Moya 的响应式生态

你现在并没有把 `RxMoya` / `CombineMoya` 当作核心架构。

当前工程主要依赖的是：

- `TargetType`
- `Provider`
- `Plugin`
- `Cancellable`

这些东西其实可以用更小的自研抽象替掉。

#### 3. Android / Web 更容易镜像

如果你换成：

- iOS: `URLSession`
- Android: `Ktor` or `OkHttp/Retrofit`
- Web: `fetch`

那么三端更容易共享同一套网络职责边界：

- request descriptor
- credential provider
- refresh coordinator
- invalidation handler
- response decoder

## 不推荐的替换方向

### 方案 A：从 `Moya` 换到 `Alamofire`

不推荐作为第一选择。

原因：

- 你现在已经不需要“再套一个重封装层”
- 迁移后仍然很难给 Android / Web 提供统一母版
- 你还是会被第三方请求生命周期模型牵着走

### 方案 B：继续保留 `Moya`，只做局部修补

短期可以，长期不建议。

原因：

- 你自己已经判断它不是理想的长期依赖
- 当前项目架构已经具备迁移窗口
- 继续拖只会增加历史包袱

## 推荐替换后的目标结构

建议 `Networking` 最终收敛成下面这组对象。

### 1. 请求描述层

保留并收敛现有：

- `CustomTargetType`

建议后续演进成：

- `RequestDescriptor`

职责：

- path
- method
- headers
- query/body parameters
- upload/download metadata

这层是三端都最值得镜像的。

### 2. 执行层

新增：

- `NetworkClient`
- `DefaultURLSessionNetworkClient`

职责：

- 根据 `RequestDescriptor` 生成 `URLRequest`
- 调用 `URLSession`
- 返回 `Data + URLResponse`

### 3. 请求构造层

新增：

- `RequestBuilder`

职责：

- 从 `CustomTargetType` 构造 `URLRequest`
- 拼接默认 headers
- 注入认证头
- 处理 GET/POST/JSON/upload/download

### 4. 会话相关层

保留并继续使用：

- `NetworkCredentialProvider`
- `TokenRefreshService`
- `SessionInvalidationHandler`
- `NetworkDependencies`

这块已经是你目前替换方案里最稳的资产。

### 5. 解码层

保留并继续使用：

- `ResponseModel<T>`
- `NetworkDecoder`
- `NetworkRequestable`

你不需要因为换掉 `Moya` 就把这些一起推翻。

### 6. 流式层

新增或改造为：

- `StreamClient`
- `URLSessionSSEClient`

职责：

- 基于 `URLSession.bytes(for:)` 读取流式内容
- 对外仍然提供你当前需要的 async stream 风格

## 当前代码应如何分阶段替换

### 阶段 1：先引入新执行层，不删 Moya

目标：

- `Moya` 仍然可用
- 新的 `URLSession` 执行链先并行存在

这一阶段要做：

1. 新增 `NetworkClient` 协议
2. 新增 `DefaultURLSessionNetworkClient`
3. 新增 `RequestBuilder`
4. 新增新的 `NetworkExecutor`
5. 让 `ResponseModel.requestable` 可以切到新执行链

这一阶段不要做：

- 不要立刻删除 `CustomTargetType`
- 不要立刻删 `NetworkAuthPlugin`
- 不要立刻删 `MoyaProvider`

### 阶段 2：把普通请求切到 URLSession

优先迁移：

- `requestable`
- `requestableWithState`
- `download`
- `upload`

迁移后结果：

- `module-ai`
- `library-common`
- `library-basics/Account`

这些上层业务不需要知道底层已经换了。

### 阶段 3：处理 402 refresh 流程

把当前 `Network.swift` 里的：

- 402 拦截
- refresh retry
- invalidate session

迁移到新的执行链中。

注意：

这部分不是 `Moya` 替换难点，真正难点是“并发下的 refresh 协调”。

建议重构目标：

- 单独的 `TokenRefreshCoordinator`

它负责：

- refresh 中状态锁
- retry queue
- timeout
- fail pending requests

### 阶段 4：流式能力替换

如果当前 SSE 还依赖旧链路，这一阶段再切。

建议：

- 普通请求先换
- SSE 后换

因为 SSE 在你的业务里主要服务 `AIChat`，它复杂度高，放后面更稳。

### 阶段 5：删掉 Moya 绑定层

最后再删：

- `CustomMultiTarget`
- `customEndpointMapping`
- `PluginType` 适配
- `MoyaProvider`
- `Moya` 包依赖

## 当前仓库里的具体改造入口

### 入口 1：`CustomTargetType`

当前问题：

- 它直接继承 `Moya.TargetType`

建议下一步：

- 保持名字不变
- 先让它不再依赖 `Moya.TargetType`
- 转成你自己的描述协议

这会是整个替换里最关键的一刀。

### 入口 2：`Network.swift`

当前问题：

- 它直接持有 `MoyaProvider`

建议下一步：

- 新增 `NetworkClient`
- 让 `Network` 从持有 `provider` 变成持有 `client`

### 入口 3：`NetworkAuthPlugin`

当前问题：

- 这是典型的 `Moya plugin` 风格

建议下一步：

- 把它变成 `RequestBuilder` 内的 header 注入逻辑

### 入口 4：`NetworkRequestable`

当前优势：

- 业务层已经通过它拿模型

建议：

- 保持对外 API 尽量不变
- 只替换内部执行路径

这会大幅降低改造面。

## 对当前项目最适合的替换顺序

按你的项目情况，建议严格按下面顺序做：

1. 设计并落 `RequestBuilder`
2. 设计并落 `NetworkClient`
3. 让 `Network.request` 支持 URLSession 执行
4. 保留 `NetworkRequestable` 对外签名不变
5. 切普通请求
6. 切 402 refresh
7. 切 SSE
8. 删 `Moya`

不要倒过来，不要先碰 SSE。

## 风险点

### 1. Header 行为差异

当前默认 header 是在 `customEndpointMapping/defaultHeaders()` 一侧组装的。

切换时容易漏掉：

- 渠道
- 设备信息
- Content-Type
- Org-Id
- Authorization

### 2. 参数编码差异

当前：

- GET 用 query string
- 其它默认 JSON pretty printed

替换时必须逐项核对。

### 3. 402 并发刷新竞态

这是最容易出问题的点。

如果多个请求同时 402：

- 只能 refresh 一次
- 其它请求要等待
- refresh 失败要统一失败

### 4. 上传下载任务能力差异

如果你后面有文件上传下载，迁移时要单独检查：

- multipart
- file upload
- download destination

## 建议的最终状态

替换完成后，理想状态应该是：

- `Networking` 不再依赖 `Moya`
- `CustomTargetType` 不再依赖第三方协议
- `NetworkDependencies` 继续保留
- `ResponseModel` / `NetworkRequestable` 继续保留
- SSE 使用 `URLSession.AsyncBytes` 或等价流式实现

## 对 Android / Web 的额外收益

一旦完成这个替换：

- iOS 会和 Android/Web 一样更贴近原生网络栈
- 你写多端网络层文档时可以直接统一为：
  - request descriptor
  - request builder
  - auth provider
  - refresh coordinator
  - session invalidation

这会显著提高 AI 跨端生成的一致性。

## 当前建议

如果你准备正式开始替换，不建议一下子开改。

更稳的下一步是：

1. 先写一版 `RequestBuilder` 设计
2. 再写 `NetworkClient` 协议和默认 `URLSession` 实现
3. 然后只切一条最小链路做 PoC

建议 PoC 目标：

- `Login.refresh`
或
- `HistoryRepository` 的简单列表请求

不要先拿 `AIChat` 做 PoC。

## 一句话结论

对你当前项目，最合理的 Moya 替换路线不是“换另一个库”，而是：

**保留你已经建立好的网络职责边界，逐步把底层执行替换成 `URLSession + 轻量自研执行层`。**

## 参考来源

- Moya GitHub Releases（最新 release 15.0.3，页面可见最新 release 与仓库活跃度信息）
  - https://github.com/Moya/Moya/releases
- Apple `URLSession.data(for:)`
  - https://developer.apple.com/documentation/foundation/urlsession/data%28for%3A%29
- Apple `URLSession.bytes(for:delegate:)`
  - https://developer.apple.com/documentation/foundation/urlsession/bytes%28for%3Adelegate%3A%29
- Apple `URLSession.AsyncBytes`
  - https://developer.apple.com/documentation/foundation/urlsession/asyncbytes
