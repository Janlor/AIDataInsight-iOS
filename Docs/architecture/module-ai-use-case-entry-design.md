# ModuleAI Use Case 层切入设计

## 文档目的

这份文档只回答一个问题：

当前 `module-ai` 如果要继续向跨平台可镜像结构推进，`use case` 层应该从哪里切入、怎么切、先切哪些。

目标不是一次性把 `module-ai` 改造成“教科书式 Clean Architecture”，而是：

- 在不打断现有 `ViewModel + Repository` 结构的前提下
- 把最容易稳定下来的业务流程先提成 application 层
- 为 Android / Web 提供更明确的可复制母版

## 当前真实状态

当前 `module-ai` 已经具备：

- `AIChatRepository`
- `HistoryRepository`
- `AIChatViewModel`
- `HistoryViewModel`
- 一批 mapper / builder / intent resolver

这说明：

- 数据访问边界已经有了
- 表现层状态对象也已经有了
- 当前缺的是“业务流程编排层”

也就是说，`use case` 现在的价值不是“把网络访问从 0 抽出来”，而是：

- 让 `ViewModel` 进一步瘦身
- 让跨平台复制时不必直接照搬 iOS ViewModel
- 让业务流程拥有比 repository 更稳定的命名和职责

## 设计原则

当前阶段建议 `use case` 只做三件事：

1. 编排多个 repository / helper / builder
2. 输出更稳定的业务结果对象
3. 作为 ViewModel 的直接依赖入口

当前阶段不建议 `use case` 做这些事：

- 直接持有 UIKit 类型
- 直接回调 controller
- 直接做路由
- 重复封装“只是把 repository 原样透传一次”的空壳 use case

## 目录建议

建议先在 `module-ai` 内部增加：

```text
ModuleAI/
  Application/
    UseCases/
      AIChat/
      History/
    Models/
```

说明：

- `Application` 比 `UseCase` 单层目录更稳
- 后续如果要加 orchestrator / facade / app-level result model，也有地方放

## 第一批最值得落的 use case

### 1. `LoadHistoryPageUseCase`

当前来源：

- `HistoryViewModel.getDataList`

建议职责：

- 调用 `HistoryRepository.loadHistoryPage`
- 调用 `HistoryListViewDataBuilder.groupRecords`
- 合并分页分组结果
- 生成 `HistorySectionViewData`

建议返回：

- `HistoryPageResult`

例如包含：

- `pageModel`
- `recordGroups`
- `sections`
- `isFirstPage`

为什么它最值得先做：

- 当前 `HistoryViewModel` 的分页、分组、合并逻辑已经比较稳定
- 这是非常典型的“application 编排层”逻辑
- Android / Web 后面都会需要同样的“分页 + 分组 + 视图列表结果”

### 2. `DeleteHistoryUseCase`

当前来源：

- `HistoryViewModel.deleteHistory`
- `HistoryViewModel.deleteAllHistory`

建议职责：

- 删除单条历史
- 删除全部历史
- 返回删除后的 `recordGroups / sections` 新状态，或者返回更明确的 mutation result

建议返回：

- `DeleteHistoryResult`

例如包含：

- `deletedHistoryId`
- `recordGroups`
- `sections`

为什么值得做：

- 这块现在仍然是“ViewModel 改本地状态 + repository 删远端”的混合逻辑
- 抽出来后，列表 mutation 规则会更容易跨平台复用

### 3. `LoadHistoryDetailUseCase`

当前来源：

- `AIChatViewModel.getHistoryDetail`

建议职责：

- 调用 `AIChatRepository.loadHistoryDetail`
- 调用现有 mapper，把 `RecordModel` 转成 `AIChat` 列表

建议返回：

- `[AIChat]`

为什么值得做：

- 这是最标准的“repository -> mapper -> presentation-ready domain output” 流程
- 非常适合作为 `AIChat` 方向的第一刀

### 4. `LoadTemplateUseCase`

当前来源：

- `AIChatViewModel.loadTemplate`

建议职责：

- 调用 `AIChatRepository.loadTemplate`
- 只返回页面真正需要的模板文案数组或包装结果

为什么值得做：

- 简单
- 可以作为第一批 use case 的最小样板
- 用于确立 `ViewModel -> UseCase -> Repository` 的依赖方向

## 第二批再做的 use case

### 1. `SendFunctionMessageUseCase`

当前来源：

- `AIChatViewModel.sendFunctionMessage`

建议职责：

- 发送问题
- 解析 `FunctionModel`
- 判断成功/失败/无函数结果
- 返回统一的 `FunctionResult`

为什么放第二批：

- 它牵涉 `FunctionModel`、`IntentResolver`、页面结果分类
- 复杂度明显高于 history 流程
- 但一旦稳定，会是 Android / Web 最有价值的母版之一

### 2. `LoadChartDataUseCase`

当前来源：

- `AIChatViewModel.getChartData`

建议职责：

- 请求图表数据
- 调用 chart builder / mapper
- 统一输出 chart result

为什么放第二批：

- 和具体图表展示耦合更深
- 适合在 `FunctionMessage` 流程稳定后再接

### 3. `StreamAIResponseUseCase`

当前来源：

- `AIChatViewModel.sendStreamMessage`

建议职责：

- 持有 `AsyncThrowingStream`
- 管理 stream 生命周期
- 输出标准化的流式事件

为什么放第二批：

- 流式逻辑已稳定，但它更偏 transport/application 交界
- 当前先保留在 `ViewModel + Repository` 之间并不算错

## 暂时不要做成 use case 的部分

下面这些当前不值得优先抽：

- 纯 repository 透传且没有编排价值的接口
- 只做 view data 展示格式转换的细小 helper
- `cancelStream()` 这类非常靠近 UI 生命周期的操作

## 建议的第一个落地顺序

建议按这个顺序做：

1. `LoadTemplateUseCase`
2. `LoadHistoryDetailUseCase`
3. `LoadHistoryPageUseCase`
4. `DeleteHistoryUseCase`
5. `SendFunctionMessageUseCase`
6. `LoadChartDataUseCase`
7. `StreamAIResponseUseCase`

这个顺序的好处是：

- 先拿简单流程建立 use case 样板
- 再处理 history 列表编排
- 最后处理 AIChat 中最复杂的函数分析和流式交互

## 对 ViewModel 的预期变化

use case 切入后，`ViewModel` 应逐步变成：

- 持有 use case
- 负责页面状态
- 负责用户交互入口
- 不再自己编排 repository + builder + mapper 细节

但当前不要求：

- 完全不碰 repository
- 一次性去掉所有 async 逻辑
- 一次性上完整 clean architecture 模板

## 一句话结论

当前 `module-ai` 的 use case 层最适合从 `History` 的分页/分组/删除编排，以及 `AIChat` 的模板/历史详情加载切入。

先把这些“真正属于 application 层”的稳定流程提出来，收益最高、风险最低，也最利于 Android / Web 镜像。
