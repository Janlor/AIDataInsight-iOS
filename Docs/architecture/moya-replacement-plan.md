# AIDataInsight 网络层替换完成记录

## 文档目的

这份文档不再是“替换方案”，而是当前仓库已经完成的网络层替换记录。

它回答三个问题：

- `Moya / Alamofire` 是否还在当前网络主链路中
- 现在的 `Networking` 到底由哪些对象组成
- 后续 Android / Web 应该镜像哪些职责，而不是镜像哪些 iOS 实现细节

## 当前结论

当前 `Networking` 主链路已经完成以下替换：

- 已移除 `Moya`
- 已移除 `Alamofire`
- 普通请求已统一到 `URLSession`
- 流式请求已统一到 `URLSession.bytes(for:)`
- 网络可达性已统一到 `NWPathMonitor`

当前网络层已经不再依赖第三方请求执行框架。

## 当前网络层结构

### 请求描述层

当前由以下类型组成：

- `TargetType`
- `RequestDescriptor`
- `Method`
- `Task`
- `ParameterEncoding`
- `JSONEncoding`
- `URLEncoding`
- `MultipartFormBodyPart`
- `MultipartFormData`
- `DownloadDestination`

这套模型现在已经是你自己的请求描述层，不再依赖 `Moya.TargetType / Moya.Task / Moya.Method`。

### 请求构造层

- `RequestBuilder`

职责：

- 从 `RequestDescriptor` 构造 `URLRequest`
- 处理 query / body / JSON / composite task
- 处理默认 header

### 执行层

- `NetworkClient`
- `URLSessionNetworkClient`
- `NetworkExecutor`

职责：

- 发送 `URLRequest`
- 返回 `Data + HTTPURLResponse`
- 处理 HTTP 状态码
- 处理 `ResponseModel` 解码
- 处理业务码 `401 / 402 / 600`

### 认证与会话层

- `NetworkCredentialProvider`
- `TokenRefreshService`
- `TokenRefreshCoordinator`
- `SessionInvalidationHandler`
- `NetworkDependencies`

职责：

- 读取 token / orgId
- 处理 refresh token
- 合并并发 `402` 刷新
- 会话失效通知

### 流式层

- `SSEClient`
- `SSEEventParser`

职责：

- 基于 `URLSession.bytes(for:)`
- 将 SSE 文本流解析为事件流
- 给 `CommonRequester.requestSSE` 和 `module-ai` 提供稳定底层

### 兼容 façade

当前还保留但内部已切换到底层新实现的对象：

- `Network`
- `NetworkRequestable`
- `CommonRequester`

保留原因：

- 不打断现有业务调用面
- 在不回退分层的前提下完成底层替换

## 402 refresh 语义当前状态

这部分是本轮替换里最关键的行为兼容点。

当前已经成立：

- 多个请求同时返回 `402`
- 只会触发一次 refresh token
- 其它请求等待同一个 refresh 结果
- refresh 成功后，每个失败请求各自自动重试一次
- refresh 失败或超时时，所有等待中的请求都会失败

这条语义当前由：

- `NetworkExecutor`
- `TokenRefreshCoordinator`
- `TokenRefreshService`

共同保证。

## 下载与上传当前状态

### 下载

已迁移到系统能力：

- `DataNetwork`
- `DownloadNetwork`

当前基于 `URLSession` 实现，不再依赖 `MoyaProvider`。

### 上传

上传描述层已经切到自定义 `Task / MultipartFormBodyPart`。

当前是否继续深化上传实现，取决于后续业务是否真的需要进一步统一到同一执行器；但它已经不再被 `Moya` 类型系统绑定。

## 网络可达性当前状态

`NetworkReachabilityAdapter` 现在基于：

- `NWPathMonitor`

不再依赖：

- `Alamofire.NetworkReachabilityManager`

上层 `library-common` 的 `NetworkMonitor` 接口不需要调整。

## 对跨平台迁移的意义

当前这套 `Networking` 已经非常接近“可镜像到 Android / Web”的状态，但还不是“可以一份代码三端共用”的状态。

### 可以直接镜像的部分

- request descriptor
- request builder
- network client
- executor
- credential provider
- refresh coordinator
- session invalidation handler
- SSE parser / stream client

这些是最值得复制到 Android / Web 的职责边界。

### 不需要镜像的部分

- `URLRequest`
- `URLSession`
- `NWPathMonitor`
- iOS 的 notification 失效通知方式

这些属于 iOS 平台实现细节，不是跨平台抽象本体。

## 当前仍然不是“完美跨平台”的点

下面这些点说明它已经“高度可迁移”，但还不能称为“完美平台无关”。

### 1. `RequestDescriptor` 已经成为当前推荐命名

当前已经完成中性化命名：

- `RequestDescriptor`

`CustomTargetType` 仅作为兼容别名保留，用于避免一次性改动所有调用点。

### 2. 错误模型仍偏 iOS 客户端语义

当前 `NetworkError` 足够稳定，但仍然是面向当前客户端实现的错误分类，不是三端统一协议错误模型。

### 3. `CommonRequester` 仍然是 iOS 业务 façade

它非常适合作为 iOS 业务层入口，但 Android / Web 不应该照搬这个名字和形式，而应该镜像职责。

## 当前建议

从今天开始，后续文档和 AI 协作应该基于这个事实：

- 不要再把当前网络层描述成“正在从 Moya 迁移”
- 应该把它描述成“已完成 URLSession 化的自定义网络层”

如果后续还要继续做：

1. 优先给 `NetworkReachabilityAdapter` 增加最小测试或手工验证记录
2. 后续新代码统一使用 `RequestDescriptor`
3. 再决定是否把 `Networking` 继续抽成更明确的 `Domain-neutral` 结构
