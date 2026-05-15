# core/network

后续封装 mock baseURL、请求、响应外壳、错误处理和 token 刷新协作。

当前已实现：

- `ApiEnvironmentProvider.ets`：读取契约中的 mock baseURL，并负责拼接接口路径。
- `ApiEnvelope.ets`：统一接口响应外壳。
- `ApiError.ets`：统一错误类型，固定 401 / 402 的 session 语义。
- `CommonRequester.ets`：统一请求入口，通过 `HttpTransport` 解耦真实网络实现。
- `MockHttpTransport.ets`：用于本地测试和 mock 链路验证。

规则：

- feature repository 不能自己拼 baseURL。
- mock URL 来自契约生成模型，不写死在子模块。
- 后续接真实 HarmonyOS HTTP API 时，只新增 `HttpTransport` 实现，不改 use case。
