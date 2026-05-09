# AIDataInsight Networking 架构定稿

## 文档目的

这份文档只描述当前仓库里已经落地的 `Networking` 结构。

它不是迁移方案，也不是理想蓝图，而是后续 iOS / Android / Web 对齐时应参考的母版。

## 当前结论

当前网络层已经完成：

- 去 `Moya`
- 去 `Alamofire`
- 去第三方请求执行框架依赖
- 切换到 `URLSession + NWPathMonitor + 自定义请求描述层`

## 当前分层

### 1. Descriptors

职责：请求描述。

核心对象：

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
- 各类 API descriptor：`OAuthApi / UploadApi / DataApi / DownloadApi`

说明：

- `CustomTargetType` 仅作为兼容别名保留
- 新代码应优先使用 `RequestDescriptor`

### 2. Builders

职责：把请求描述转换成平台请求对象。

核心对象：

- `RequestBuilder`

### 3. Execution

职责：执行普通请求并处理状态码、业务码、解码失败。

核心对象：

- `NetworkClient`
- `URLSessionNetworkClient`
- `NetworkExecutor`
- `NetworkResponse`
- `NetworkError`

### 4. Session

职责：认证信息、刷新 token、会话失效。

核心对象：

- `NetworkCredentialProvider`
- `TokenRefreshService`
- `TokenRefreshCoordinator`
- `SessionInvalidationHandler`
- `NetworkDependencies`

关键语义：

- 多请求同时 `402`
- 只 refresh 一次
- refresh 成功后各自自动重试一次
- refresh 失败或超时则所有 waiter 一起失败

### 5. Decoding

职责：统一响应壳和解码相关错误。

核心对象：

- `ResponseModel`
- `ResponseError`

### 6. Streaming

职责：SSE 与流式文本解析。

核心对象：

- `SSEClient`
- `SSEEventParser`

说明：

- 当前基于 `URLSession.bytes(for:)`
- 不再依赖旧的 delegate buffering 方案

### 7. Reachability

职责：网络可达性状态监听。

核心对象：

- `NetworkReachabilityAdapter`

说明：

- 当前基于 `NWPathMonitor`

### 8. Transfers

职责：二进制下载、文件落盘、下载缓存短路。

核心对象：

- `DataNetwork`
- `DownloadNetwork`
- `URLSessionTransfer`

### 9. Compatibility

职责：兼容旧调用面，避免一次性改坏业务层。

核心对象：

- `Network`
- `NetworkRequestable`

说明：

- 这一层不是未来 Android / Web 要照搬的结构
- 它主要服务于当前 iOS 工程的平滑演进

## 跨平台迁移建议

Android / Web 应重点镜像这些职责，而不是镜像 iOS 具体类名：

- request descriptor
- request builder
- network executor
- credential provider
- refresh coordinator
- session invalidation handler
- streaming client
- reachability adapter

不需要镜像的 iOS 细节：

- `URLRequest`
- `URLSession`
- `NWPathMonitor`
- `NotificationCenter`

## 当前建议

从现在开始：

- 新代码优先用 `RequestDescriptor`
- 不再把 `Networking` 描述成 “Moya 风格封装”
- Android / Web 设计时直接按这份分层对齐
