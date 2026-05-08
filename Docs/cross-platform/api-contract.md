# AIDataInsight API Contract

## 文档目的

这份文档定义 AIDataInsight 当前四端应该共享的 API 契约母版。

它回答的是：

- 请求路径是什么
- 请求方法是什么
- 请求参数名是什么
- 响应外壳长什么样
- 会话失效与刷新规则是什么
- 哪些接口存在动态参数或动态返回结构

它不描述：

- iOS 用 `Networking`
- Android 用 Ktor 还是 Retrofit
- Web 用 fetch 还是 axios

这些都属于实现细节，不属于 API 契约。

---

## 1. 总体规则

### 1.1 Base URL

当前 iOS 通过 `NetworkServer.baseURL` 提供 host。

跨端要求：

- host 作为环境配置注入
- 不写死在 feature 内
- DEV / PRE / PROD 必须可切换

### 1.2 默认请求方式

来源：

- `Packages/library-basics/Sources/Networking/Descriptors/RequestDescriptor.swift`

规则：

- 默认 `baseURL` 由环境提供
- 默认 `path` 可以为空，但业务接口都应显式声明
- 默认 `method` 为 `POST`
- `GET` 请求使用 query string
- 其它方法当前默认使用 JSON body 风格参数编码

### 1.3 统一响应外壳

来源：

- `Packages/library-basics/Sources/Networking/Decoding/ResponseModel.swift`

Canonical Response Envelope:

```json
{
  "msg": "string?",
  "code": 200,
  "data": {},
  "trace": "string?",
  "tid": "string?"
}
```

字段语义：

- `msg`
  - 服务端消息
- `code`
  - 业务状态码
- `data`
  - 业务数据
- `trace`
  - trace 标识
- `tid`
  - 请求关联标识

### 1.4 错误规则

来源：

- `Packages/library-basics/Sources/Networking/Decoding/ResponseError.swift`

Canonical Error Types:

- `unknown`
- `dataFormat`
- `server(code, msg)`

跨端要求：

- 至少要保留 `code` 和 `msg`
- 任何端都不能只保留一段纯文本错误，丢掉业务 code

### 1.5 会话规则

来源：

- `Packages/library-basics/Sources/Networking/Decoding/ResponseModel.swift`
- `Packages/library-basics/Sources/Networking/Session/NetworkDependencies.swift`

当前已知业务码语义：

- `401`
  - session 失效，需要重新登录
- `402`
  - access token 过期，需要自动 refresh

跨端要求：

1. 请求失败命中 `402` 时
   - 先尝试 refresh token
2. refresh 成功后
   - 重试原请求
3. refresh 失败或命中 `401` 时
   - 清空 session
   - 触发统一 logout / re-auth 流程

---

## 2. 认证接口

来源：

- `Packages/library-common/Sources/Login/Repositories/APIs/OAuthApi.swift`
- `Packages/library-basics/Sources/Networking/Descriptors/OAuthApi.swift`

### 2.1 Login

```text
POST /oauth2/login
```

Parameters:

```json
{
  "name": "string",
  "pwd": "string"
}
```

Response:

- `ResponseModel<OAuthModel>`

说明：

- 当前 iOS 在 repository 层负责密码加密与会话更新
- 跨端必须保持参数名 `name` / `pwd`

### 2.2 Refresh Token

```text
GET /oauth2/refresh
```

Parameters:

```json
{
  "refreshToken": "string"
}
```

Response:

- `ResponseModel<OAuthModel>`

### 2.3 Logout

```text
GET /oauth2/logout
```

Parameters:

```json
{}
```

Response:

- `ResponseModel<EmptyModel>` 或等价空载荷

---

## 3. 账户接口

来源：

- `Packages/library-basics/Sources/Account/Api/AccountApi.swift`

### 3.1 Get User Info

```text
GET /oauth2/getUserInfo
```

Parameters:

```json
{}
```

Response:

- `ResponseModel<UserInfo>`

### 3.2 Update Password

```text
POST /oauth2/updatePwd
```

Parameters:

```json
{
  "oldPwd": "string",
  "newPwd": "string"
}
```

Response:

- `ResponseModel<EmptyModel>` 或等价空载荷

### 3.3 Get Menu Tree

```text
GET /oauth2/menuTree
```

Parameters:

```json
{}
```

Response:

- `ResponseModel<[MenuItem]>`

---

## 4. 历史会话接口

来源：

- `Packages/module-ai/Sources/ModuleAI/Repositories/History/HistoryApi.swift`

### 4.1 Page History

```text
GET /history/page
```

Parameters:

```json
{
  "currentPage": 1,
  "pageSize": 20
}
```

Response:

- `ResponseModel<RecordPage>`

### 4.2 History Detail

```text
GET /history/detail
```

Parameters:

```json
{
  "historyId": 123
}
```

Response:

- `ResponseModel<HistoryRecord>` 或与当前 iOS 对应的单条记录详情结构

说明：

- 当前 iOS 实际使用 `RecordModel.detailList`
- 跨端语义上应理解为“按 `historyId` 取完整会话记录”

### 4.3 Like / Unlike History Detail

```text
POST /history/like
```

Parameters:

```json
{
  "historyDetailId": 456,
  "like": "1"
}
```

说明：

- `like` 当前是字符串语义，不是布尔值
- 已知业务语义：
  - `"1"` = 赞
  - `"0"` = 踩

Response:

- `ResponseModel<EmptyModel>` 或等价空载荷

### 4.4 Delete One History

```text
GET /history/delete
```

Parameters:

```json
{
  "historyId": 123
}
```

Response:

- `ResponseModel<EmptyModel>` 或等价空载荷

### 4.5 Delete All History

```text
GET /history/deleteAll
```

Parameters:

```json
{}
```

Response:

- `ResponseModel<EmptyModel>` 或等价空载荷

---

## 5. AI Chat 接口

来源：

- `Packages/module-ai/Sources/ModuleAI/Repositories/AIChat/ChatApi.swift`
- `Packages/module-ai/Sources/ModuleAI/Repositories/AIChat/FunctionResponseDTO.swift`

### 5.1 Load Chat Template

```text
GET /chat/template
```

Parameters:

```json
{}
```

Response:

- `ResponseModel<TemplateQuestionSet>`

### 5.2 Function Analysis

```text
GET /chat/function
```

Parameters:

```json
{
  "question": "string",
  "historyId": 123
}
```

说明：

- `historyId` 可选
- 用于在已有历史上下文中继续提问

Response:

- `ResponseModel<FunctionResponse>`

Canonical FunctionResponse:

```json
{
  "historyId": 123,
  "hasTool": true,
  "name": "querySalesGroupByMonth",
  "msg": "string?",
  "arguments": {}
}
```

### 5.3 Function Response Dynamic Arguments

这是当前最关键的动态契约之一。

`arguments` 的结构由 `name` 决定。

#### basic

适用于：

- `queryArGroupByOrg`
- `queryArGroupByCustomer`
- `queryAccountGroupByAge`

Shape:

```json
{
  "orgId": 1,
  "customerName": "string?",
  "orderType": "string?",
  "operator": "string?",
  "value": 0.0
}
```

#### timeRange

适用于：

- `querySalesGroupByOrgAndGoodsType`
- `querySalesGroupByMonth`
- `querySalesGroupByCustomer`
- `queryPurchaseGroupByOrg`
- `queryPurchaseGroupByMonth`
- `queryPurchaseGroupByCustomer`

Shape:

```json
{
  "startDate": "string?",
  "endDate": "string?",
  "orgId": 1,
  "customerName": "string?",
  "goodsType": 1,
  "orderType": "string?",
  "operator": "string?",
  "value": 0.0
}
```

#### warehouse

适用于：

- `queryStockGroupByOrg`
- `queryStockGroupByWarehouse`
- `queryInventoryGroupByOrg`
- `queryInventoryGroupByWarehouse`
- `queryProcurementGroupByOrg`
- `queryProcurementGroupByCustomer`

Shape:

```json
{
  "orgId": 1,
  "warehouseName": "string?",
  "goodsType": 1,
  "orderType": "string?",
  "operator": "string?",
  "value": 0.0
}
```

#### accountAge

适用于：

- `queryAccountAgeGroupByOrg`
- `queryAccountAgeGroupByCustomer`

Shape:

```json
{
  "orgId": 1,
  "customerName": "string?",
  "orderType": "string?",
  "valueArray": ["30", "60", "90"]
}
```

#### performanceType

适用于：

- `queryPerformanceType`

Shape:

```json
{
  "indexType": "string?"
}
```

跨端要求：

- `name -> arguments schema` 映射必须一致
- 不能某一端把动态解码偷简化成裸字典后长期不建模

---

## 6. 图表接口

来源：

- `Packages/module-ai/Sources/ModuleAI/Repositories/AIChat/ChartApi.swift`

### 6.1 Generic Chart Request

```text
GET /chart/{functionName}
```

Path Variable:

- `{functionName}` = `FunctionName.rawValue`

Parameters:

- `historyId: Int`
- 其余参数来自对应的 `FunctionArguments`

示例：

```text
GET /chart/querySalesGroupByMonth
```

Example Parameters:

```json
{
  "historyId": 123,
  "startDate": "2026-01-01",
  "endDate": "2026-01-31",
  "orgId": 1,
  "customerName": "string?",
  "goodsType": 1,
  "orderType": "string?",
  "operator": "string?",
  "value": 0.0
}
```

Response:

- `ResponseModel<HistoryChartDetail>`

说明：

- 图表接口不是 17 个硬编码 endpoint，而是统一的 `/chart/{name}`
- 各端不要重新分叉为各自不同的路径拼接规则

---

## 7. Header / Session Context

来源：

- `Packages/library-basics/Sources/Networking/Descriptors/RequestDescriptor.swift`

当前已知规则：

- cache key 计算会显式考虑 `Org-Id`
- 如果 header 中没有 `Org-Id`
  - 会回退到 `NetworkDependencies.credentialProvider.orgId`

跨端要求：

- `Org-Id` 视为重要请求上下文字段
- 任何需要组织上下文的请求，必须支持从 session 注入该值

---

## 8. 缓存键规则

来源：

- `Packages/library-basics/Sources/Networking/Descriptors/RequestDescriptor.swift`

当前缓存键由以下部分组成：

1. `path`
2. `method`
3. `Org-Id`
4. 排序后的 `parameters`

最终对原始串做 MD5。

跨端要求：

- 如果某端实现请求缓存，必须遵守等价规则
- 不能出现同一路径但不同 orgId 命中同一缓存的情况

---

## 9. 同步规则

当 API 契约变化时，顺序必须是：

1. 先更新本文件
2. 再更新 `Docs/cross-platform/domain-models.md` 中受影响模型
3. 再更新 iOS 当前实现
4. 再同步 Android / Web / Desktop
5. 最后在 `Docs/cross-platform/change-log.md` 追加记录

---

## 10. 当前已知缺口

这份初稿还没有展开：

- SSE / streaming 详细协议
- 文件上传下载契约
- 更完整的错误码表
- 鉴权 header 全量规则
- DTO 到 domain 的字段映射表

这些建议在下一轮按需要补齐。

---

## 一句话结论

四端 API 同步的关键不是“都用同一个网络库”，而是都遵守这份接口路径、参数命名、响应外壳和会话规则母版。
