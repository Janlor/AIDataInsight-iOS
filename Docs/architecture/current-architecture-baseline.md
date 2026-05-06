# AIDataInsight 当前架构基线

## 文档目的

这份文档只记录当前仓库里已经真实落地的结构、依赖约束和后续演进规则。

它不是目标蓝图，也不是理想方案。

它回答三个问题：

- 现在代码已经重构到什么程度
- 当前各模块应该如何理解
- 后续继续改造时，哪些约束不能退回去

## 当前总体判断

当前工程已经从“壳工程 + 大型 UIKit 功能包”进入到“壳工程 + 模块化业务包 + 初步分层”的阶段。

真实状态如下：

- 主工程 `AIDataInsight` 仍然是 iOS 壳层
- `module-ai` 已完成第一轮 `Domain / Repositories / Presentation / Views` 化
- `library-common` 的 `Login / Setting / Privacy` 已完成第一轮 `Domain / Repository / Presentation` 化
- `library-basics` 的 `Networking` 和 `AccountProtocol` 已完成第一轮边界收窄

这意味着：

- 业务层已经不再完全绑死在 `UIViewController + callback + Router.perform(AccountProtocol.self)` 上
- Android / Web 已经可以开始按当前结构做镜像设计
- 但当前仍然不是“可直接共享代码”的状态，而是“可稳定迁移和复制结构”的状态

## 主工程层

主工程 `AIDataInsight` 仍然承担这些职责：

- 生命周期转发
- 装配各个 package
- 提供最终 App target

这层暂时不需要继续大改。跨平台意义主要在于：

- 它已经是一个很薄的壳
- 真正要迁移的是 `Packages` 里的业务和基础能力

## module-ai 当前基线

`module-ai` 现在已经完成了第一轮结构调整。

### 已落地的结构

当前内部按以下方向组织：

- `Domain`
- `Repositories`
- `Presentation`
- `Views`

### 已完成的关键改造

#### 1. `CommonRequester` 已支持 async/await

已增加：

- 单次请求 async bridge
- void 请求 async bridge
- SSE 的 `AsyncThrowingStream`

这使得 `module-ai` 和 `library-common` 后续都可以逐步摆脱 callback 风格。

#### 2. `History` 已完成第一轮拆分

当前 `History` 已形成：

- `HistoryRepository` 协议
- `DefaultHistoryRepository`
- `HistoryViewModel`
- `HistoryListViewData`

其意义是：

- `ViewModel` 不再直接依赖 `CommonRequester`
- 领域数据和 UIKit 展示数据已经分开

#### 3. `AIChat` 已完成第一轮拆分

当前 `AIChat` 已形成：

- `AIChatRepository` 协议
- `DefaultAIChatRepository`
- `AIChatViewModel`
- `AIChatIntentResolver`
- `AIChatChartBuilder`
- `AIChatHistoryMapper`

其意义是：

- 网络请求、SSE、意图判断、图表转换不再全部堆在一个 `ViewModel`
- 控制器开始通过 async 方式驱动

#### 4. `Domain/Models` 已完成一轮清理

已经做掉的事情：

- `AIChat` 从 Domain 挪到 Presentation
- `DetailModel` 不再持有展示层派生对象
- 历史消息解析挪到 mapper/helper
- `Networking` 相关 conformances 从部分 domain model 中移出

#### 5. `FunctionModel` 边界已进一步收清

已经形成：

- `FunctionName`
- `FunctionArguments`
- 查询参数模型
- `FunctionResponseDTO`

当前规则是：

- Domain 只表达函数语义和参数语义
- 动态解码策略属于 Data / Repositories

### 当前仍保留的现实情况

`module-ai` 还不是纯领域包，仍然保留：

- `UIKit`
- `BaseUI`
- `Router`
- 图表视图实现

这没有问题。当前目标不是让它变成跨平台共享源码，而是让它的结构足够稳定，便于 AI 和人工复制到 Android / Web。

## library-common 当前基线

`library-common` 当前更适合被理解为“公共业务模块层”，不是纯 common/core。

### Login

`Login` 已经完成第一轮拆分：

- `LoginRepository`
- `DefaultLoginRepository`
- `LoginViewModel`
- `LoginViewController`

当前规则：

- 登录控制器只负责 UI、输入校验、交互
- 密码加密和登录请求在 repository
- 登录成功后更新会话通过 `AccountSessionStore`

### Setting

`Setting` 已经完成第一轮拆分：

- `SettingSnapshot`
- `SettingCapability`
- `SettingRepository`
- `DefaultSettingRepository`
- `SettingViewModel`
- `SettingViewData`

当前规则：

- repository 负责聚合账户、隐私、登录等服务能力
- `ViewModel` 负责把 snapshot 变成视图数据
- controller 负责 table view 和路由触发

并且依赖已经开始收窄：

- 资料读取依赖 `AccountUserStore`
- 修改密码入口依赖 `AccountRouteService`
- 退出登录依赖 `LoginProtocol`

### Privacy

`Privacy` 已经完成第一轮拆分：

- `PrivacyRepository`
- `DefaultPrivacyRepository`
- `PrivacyPolicyViewModel`
- `PrivacyPolicyAlertContent`

当前规则：

- 是否需要弹窗、弹窗文案、同意后的持久化不再直接堆在 router 里
- router 只保留 UIKit 弹窗和页面跳转壳层职责

### AppMain

`AppMain` 已经开始依赖更窄的账户协议：

- 登录态判断依赖 `AccountSessionStore`
- 清理会话依赖 `AccountSessionStore`

## library-basics 当前基线

`library-basics` 目前仍然是“基础设施 + iOS 平台适配 + 账户 + 网络”的混合层，但已经完成第一轮边界收窄。

### Networking

这是当前仓库最接近“可跨平台镜像”的基础设施层。

当前已经真实落地：

- 自定义请求描述层
  - `TargetType`
  - `CustomTargetType`
  - `Method`
  - `Task`
  - `ParameterEncoding`
- 请求构造层
  - `RequestBuilder`
- 执行层
  - `NetworkClient`
  - `URLSessionNetworkClient`
  - `NetworkExecutor`
- 依赖层
  - `NetworkCredentialProvider`
  - `TokenRefreshService`
  - `TokenRefreshCoordinator`
  - `SessionInvalidationHandler`
  - `NetworkDependencies`
- 流式层
  - `SSEClient`
  - `SSEEventParser`
- 可达性层
  - `NetworkReachabilityAdapter`
  - `NWPathMonitor`

当前已经移除：

- `Moya`
- `Alamofire`
- `MoyaProvider`
- `NetworkAuthPlugin`
- `CustomMultiTarget`

当前规则：

- 网络层不再直接依赖第三方请求执行框架
- 网络层通过依赖注入接触会话能力
- 并发 `402` 只 refresh 一次，成功后各请求自动重试一次
- 业务层继续通过 `CommonRequester / NetworkRequestable / Network` 这些 façade 使用新链路

这一步的意义非常大：

- Android / Web 可以直接镜像网络职责边界
- 只需替换平台实现，不必重想架构职责

### AccountProtocol

`AccountProtocol` 不再是唯一入口，当前已经拆成：

- `AccountSessionStore`
- `AccountUserStore`
- `AccountRemoteService`
- `AccountRouteService`
- `AccountProtocol` 作为组合协议继续保留兼容

当前规则：

- 会话状态、用户数据、远程账户服务、UIKit 路由行为必须分开理解
- 后续新代码优先依赖子协议，不再默认依赖整个 `AccountProtocol`

### AccountRouter

`AccountRouter` 已不再承担远程账户请求。

当前状态：

- 本地会话和用户存储能力仍由它承接
- UIKit 路由能力仍由它承接
- 远程请求已抽到 `DefaultAccountRemoteService`

这说明：

- 结构已经清楚
- `Account` 相关职责已经比第一阶段更稳定

### 已经开始生效的窄依赖

当前这些依赖已经收窄：

- `Networking -> AccountSessionStore`
- `Login -> AccountSessionStore`
- `AppMain -> AccountSessionStore`
- `Setting -> AccountUserStore`
- `Setting -> AccountRouteService`

这条规则后续必须保持。

## 当前必须遵守的约束

后续继续改造时，以下规则不能回退。

### 1. 新业务代码不要再默认依赖整包 `AccountProtocol`

优先选择：

- `AccountSessionStore`
- `AccountUserStore`
- `AccountRemoteService`
- `AccountRouteService`

只有在确实同时需要多种能力时，才允许依赖组合协议。

### 2. 新网络能力不要直接读取 Router 或 NotificationCenter 处理会话

网络层只能通过：

- `NetworkCredentialProvider`
- `TokenRefreshService`
- `SessionInvalidationHandler`

接触会话逻辑。

### 3. Domain 模型不再引入 UIKit 展示数据

禁止再把这些东西放回 Domain：

- `UIImage`
- `UIColor`
- `UIFont`
- `NSAttributedString`
- `UITableViewCell.SelectionStyle`

它们只能出现在 Presentation / ViewData / Views。

### 4. ViewModel 不再直接承担所有网络和解析逻辑

优先顺序必须是：

- Repository 负责数据访问
- Helper / Mapper 负责转换
- ViewModel 负责状态和编排

### 5. Router 继续视为 iOS 适配层，不作为跨平台共享层

不要试图把当前 `Router` 变成跨平台核心抽象。

正确理解是：

- iOS 有自己的 Router adapter
- Android 有自己的 Navigation adapter
- Web 有自己的 route adapter

共享的是意图和状态，不是 UIKit 路由实现。

## 当前还没有完成的部分

下面这些事还没做完，但已经有清楚入口。

### 1. `Environment` 仍然偏 iOS 运行时配置层

它还不是多端共享配置中心。

后续需要把：

- 环境值
- 服务地址
- 渠道信息

和平台运行时能力继续分开。

### 2. `module-ai` 还没有 use case 层

现在有 repository 和 viewmodel，但还没有明确的 use case 层。

如果后续要进一步为 Android/Web 提供稳定生成基线，这层可以补。

### 3. 测试仍然偏少

当前最值得补的测试优先是：

- `NetworkReachabilityAdapter`
- `CommonRequester` 在新网络链路上的边界行为
- 上传 / 下载链路
- `module-ai` 更多非 happy path 场景

## 建议的下一步

如果继续往下做，优先级建议如下：

1. 给当前网络层和上传/下载补收尾测试
2. 审查 `Environment`，区分配置数据和 iOS 运行时适配
3. 视需要给 `module-ai` 增加 use case 层
4. 再决定是否开始 Android/Web 初始仓库搭建

## 一句话结论

当前仓库已经完成了“跨平台迁移前的第一阶段基础改造”。

它还没有进入“共享代码”阶段，但已经进入“结构可迁移、职责可映射、AI 可稳定协作生成多端代码”的阶段。
