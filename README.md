# AIDataInsight-iOS

AIDataInsight-iOS 是一个基于 UIKit + Swift Package Manager 的 AI 数据分析 Demo。项目围绕“自然语言提问 -> AI 理解 -> 数据查询 / 图表展示 -> 对话式反馈”这条链路实现，并已经落地了聊天页面的流式响应能力。

## 项目目标

- 展示 AI 数据分析助手在 iOS 端的产品形态
- 用模块化工程组织业务模块、通用业务能力和基础设施
- 演示 Function Calling 场景下的意图识别、查询编排和图表渲染
- 支持流式 AI 回复，提供更自然的聊天交互体验

## 当前工程结构

仓库当前由壳工程 + Swift Package 模块组成：

```text
AIDataInsight-iOS
├── AIDataInsight/              # iOS App 壳工程
├── Packages/
│   ├── module-ai/             # AI 数据分析业务模块
│   ├── library-common/        # 通用业务能力 / 协议层
│   └── library-basics/        # 基础设施能力
└── Docs/                      # 文档与架构说明
```

### App 壳工程

`AIDataInsight/AIDataInsight` 负责应用入口、`AppDelegate`、`SceneDelegate`、`Info.plist`、环境配置和产物装配。

### ModuleAI

`Packages/module-ai` 是当前最核心的业务模块，包含：

- `AIChatViewController`：聊天页面 UI、列表刷新、输入交互、流式渲染
- `AIChatViewModel`：历史记录、模板加载、函数调用分析、图表查询编排
- `AIChat` / `FunctionModel` / `HistoryDetailModel`：聊天和业务模型
- `ChatApi` / `HistoryApi` / `ChartApi`：AI 聊天与历史接口定义
- 各类聊天 Cell：欢迎语、用户消息、AI 文本、意图提示、图表展示

### LibraryCommon

`Packages/library-common` 提供业务通用层：

- `CommonViewModel`：业务 ViewModel 的公共依赖出口
- `CommonRequester`：统一请求入口
- `ProtocolAI` / `LoginProtocol` / `PrivacyProtocol` / `SettingProtocol`：模块解耦协议

### LibraryBasics

`Packages/library-basics` 提供基础设施能力：

- `Networking`：Moya / 网络封装 / 统一响应模型
- `SSEClient`：基于 `URLSession + dataTask` 的流式 SSE 客户端
- `BaseViewModel`：任务管理与取消
- `BaseUI` / `BaseKit`：UI 组件和通用工具
- `Router` / `Environment` / `AccountProtocol` 等基础能力

## AI 聊天主链路

当前聊天分析链路分成两条：

### 1. 函数调用 / 图表分析链路

```text
用户输入
-> AIChatViewController
-> AIChatViewModel.sendFunctionMessage
-> ChatApi.function
-> FunctionModel / Intent 判断
-> ChartApi.chart
-> AIChatChartCell / AIChatLegendChartCell
```

适用于需要结构化参数和图表结果的分析型问题。

### 2. 流式回复链路

```text
用户输入
-> AIChatViewController
-> AIChatViewModel.sendStreamMessage
-> CommonRequester.requestSSE
-> SSEClient
-> chunk 累积
-> CADisplayLink 节流渲染
-> AIChatCell 增量刷新
```

当前已接入 mock 流式接口：

`https://m1.apifoxmock.com/m1/3174267-1700689-default/stream`

## 流式响应设计

流式渲染不是直接把收到的 chunk 立刻全量刷到 UI，而是分成两层：

- 网络层：`CommonRequester` 调用 `Networking/SSEClient` 快速接收 SSE `data:` 事件，并累积到 `pendingStreamText`
- 渲染层：通过 `CADisplayLink` 控制输出节奏，将文本按“英文单词边界 + 中文逐字”推进到 `renderedStreamText`

这样即使服务端在极短时间内返回完所有 chunk，聊天气泡仍然可以以更自然的打字机效果显示。

为了减少换行时的列表跳动，当前实现避免在每一帧使用 `performBatchUpdates(nil)` 做动画布局，而是用无动画的 layout invalidation 和底部对齐来稳定高度变化。

## 技术栈

- Swift
- UIKit
- Swift Package Manager
- MVVM（Closure 回调风格）
- Moya / Alamofire 风格网络封装
- DGCharts
- URLSession SSE

## 文档

- 架构设计说明书：[Docs/架构设计说明书.md](Docs/架构设计说明书.md)
- Mermaid 索引说明：[Docs/组件依赖关系图.mmd.md](Docs/组件依赖关系图.mmd.md)
- 高层依赖图源文件：[Docs/组件依赖关系图-高层.mmd](Docs/组件依赖关系图-高层.mmd)
- 详细依赖图源文件：[Docs/组件依赖关系图-详细.mmd](Docs/组件依赖关系图-详细.mmd)
- 组件依赖关系图：`Docs/组件依赖关系图.pdf`

### 图文档维护

建议把下面几类文件一起提交，保持“源图 + 导出产物”一致：

- `.mmd`：Mermaid 源文件，作为唯一可维护文本来源
- `.svg`：便于网页查看和矢量对比
- `.pdf`：便于文档分发和评审

推荐更新步骤：

```bash
./scripts/export-mermaid-diagrams.sh
```

当组件依赖发生变化时：

1. 先修改 `.mmd` 源文件
2. 再执行导出脚本生成 `.svg` 和 `.pdf`
3. 最后将源文件和导出产物一并提交

## Demo

<img src="https://github.com/Janlor/AIDataInsight-iOS/blob/main/images/history.png" width="402"> <img src="https://github.com/Janlor/AIDataInsight-iOS/blob/main/images/chat.png" width="402">

## 说明

- 当前仓库以 Demo 和架构演示为主，部分数据来源为 mock
- AI 聊天既支持函数调用分析，也支持文本流式回复
- README 与 Docs 已按当前项目实际落地情况更新
