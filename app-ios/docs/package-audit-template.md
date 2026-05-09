# Packages 审计模板

## 文档用途

这份模板用于逐文件审计 `Packages/module-ai`、`Packages/library-basics`、`Packages/library-common`，目标不是做一次泛泛梳理，而是识别：

- 哪些代码已经接近平台无关
- 哪些代码仍然强依赖 iOS
- 哪些地方应该优先改 `async/await`
- 哪些职责需要从 `ViewModel`、模型或 Router 中剥离

## 结合本项目的分类标准

### 1. 领域层 Domain

可以包含：

- 实体
- 值对象
- 用例协议
- 仓储协议
- 纯业务规则
- 平台无关错误模型

不应该包含：

- `UIKit`
- `SwiftUI`
- `NSAttributedString`
- `UIViewController`
- `NotificationCenter`
- `Router`
- `NSLocalizedString`

### 2. 数据层 Data

可以包含：

- API target
- DTO
- repository 实现
- mapper
- cache adapter
- 请求组装

不应该包含：

- 控制器跳转
- view state
- UIKit UI 格式化

### 3. 表现层 Presentation

可以包含：

- `ViewController`
- `ViewModel`
- Cell
- 自定义 View
- iOS 图表展示模型
- 页面本地化和布局行为

### 4. 平台层 Platform

可以包含：

- `AppDelegateModule`
- iOS 路由注册
- 生命周期桥接
- 推送、相册、相机、Keychain 等平台能力接入

## 本项目重点关注的问题

### `module-ai`

重点检查：

- `ViewModel` 是否直接发网络请求
- 模型是否混入 `UIKit`
- 图表逻辑是否混合领域和显示规则
- SSE 是否仍然只有 callback 入口
- Router 是否暴露 UIKit 跳转

### `library-basics`

重点检查：

- 哪些 target 是平台无关基础能力
- 哪些 target 实际是 iOS UI 基础库
- `Networking` 是否能增加 async bridge
- `AccountProtocol` / `Router` 是否过早暴露 UIKit

### `library-common`

重点检查：

- 协议 target 和实现 target 是否已经分离
- `CommonViewModel` 是否成为所有业务的“默认网络入口”
- 登录/设置/隐私模块是否直接依赖 UIKit

## 逐文件审计表

每个文件一行，建议放到表格工具里持续维护。

| 文件 | 所属包 | 当前层级 | 依赖 UIKit/平台 API | 直接网络调用 | Callback 异步 | 共享可变状态 | 建议动作 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `AIChatViewModel.swift` | `module-ai` | `Presentation + Data` | `否` | `是` | `是` | `是` | 抽 repository，改 async |

## 审计时要回答的问题

对每个文件都回答这 8 个问题：

1. 这个文件现在属于 Domain / Data / Presentation / Platform 的哪一层？
2. 它的命名和职责是否一致？
3. 它有没有直接依赖 `UIKit`、`Router`、`NotificationCenter`、`CommonRequester`？
4. 它暴露的是 callback 还是 `async/await`？
5. 它是否在做本不属于自己的事？
6. 它能否被 Android/Web 按同样契约实现？
7. 它是否适合作为第一批迁移样板？
8. 它迁移后应该放在哪个目录或 target 下？

## 搜索清单

优先搜索这些依赖扩散点：

- `import UIKit`
- `import Router`
- `import CommonViewModel`
- `import Networking`
- `NotificationCenter.default`
- `DispatchQueue.main`
- `DispatchQueue.global`
- `CommonRequester.`
- `Router.present`
- `Router.push`
- `NSAttributedString`
- `URLRequest(`

## async/await 迁移清单

每发现一个异步 API，都记录下面这些内容：

| 当前 API | 所在文件 | 类型 | 调用方 | UI 线程假设 | 迁移目标 |
| --- | --- | --- | --- | --- | --- |
| `requestNet(_:completion:)` | `CommonRequester.swift` | 单次请求 | 多个 ViewModel | 有 | `async throws -> T` |
| `requestSSE(_:onEvent:completion:)` | `CommonRequester.swift` | 流式事件 | `AIChatViewModel` | 有 | `AsyncThrowingStream<String, Error>` |

类型建议只分三类：

- 单次请求
- 连续事件流
- 可取消长任务

## adapter 抽取清单

凡是依赖 iOS 平台对象的能力，都记录为 adapter 候选：

| 当前能力 | 当前位置 | 目标协议 | 目标实现位置 | 备注 |
| --- | --- | --- | --- | --- |
| 生命周期注入 | `AppLaunch/Application.swift` | 暂不抽离 | `library-basics` iOS 层 | 先保留 |
| 页面路由 | `Router.swift` | `RouteIntent` + presenter | iOS presentation/platform | 分阶段改 |
| 历史删除通知 | `HistoryViewController.swift` | `HistoryEventStream` 或状态刷新 | `module-ai` 内部 | 后续处理 |

## 对 `module-ai` 的建议审计顺序

按这个顺序看，效率最高：

1. `AIChat/ViewModels/AIChatViewModel.swift`
2. `History/ViewModels/HistoryViewModel.swift`
3. `Api/*.swift`
4. `History/HistoryModel.swift`
5. `AIChat/Models/FunctionModel.swift`
6. `AIChat/Models/HistoryDetailModel.swift`
7. `Router/ModuleAIRouter.swift`
8. `AppDelegate/AppDelegate.swift`
9. `AIChatViewController.swift`
10. `HistoryViewController.swift`

原因：

- 先抓异步边界
- 再抓模型边界
- 最后看 UI 绑定和路由

## 每个文件迁移完成的判定标准

一个文件算完成迁移，需要同时满足：

- 职责和目录位置一致
- 平台相关依赖没有继续向下层泄漏
- 异步接口风格统一
- 共享状态归属明确
- Android/Web 可以依据同一契约复刻其行为

## 当前已知样例结论

根据这次已读取的真实代码，先给出几个已确认项：

| 文件 | 初步结论 |
| --- | --- |
| `AIChatViewModel.swift` | 不是纯 ViewModel，混有数据访问、SSE、意图判断、图表转换 |
| `HistoryViewModel.swift` | 结构比 AIChat 更清晰，适合作为第一个 async 样板 |
| `HistoryModel.swift` | 领域模型和 UIKit 展示数据混在一起 |
| `CommonRequester.swift` | 是 async/await 迁移的第一入口 |
| `Router.swift` | 当前是 UIKit 路由，不是跨平台路由模型 |
