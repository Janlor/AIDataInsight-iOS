# ModuleAI Use Case 层切入与当前落地状态

## 文档目的

这份文档同时回答两件事：

- `module-ai` 的 use case 层为什么这样切
- 当前这轮改造已经真实落到哪一步

它不再只是“切入设计”，也作为当前 `module-ai` application 层的阶段性记录。

## 当前真实状态

当前 `module-ai` 已经具备：

- `AIChatRepository`
- `HistoryRepository`
- `AIChatViewModel`
- `HistoryViewModel`
- 一批 mapper / builder / intent resolver
- 一批已经落地并接入 `ViewModel` 的 use case

这说明 `module-ai` 当前已经不是“只有 repository 的 MVVM”，而是已经形成了第一轮 application 编排层。

## 当前目录

当前 `module-ai` 已经形成：

```text
ModuleAI/
  Application/
    UseCases/
      AIChat/
      History/
  Domain/
    AIChat/
    History/
  Presentation/
    App/
    AIChat/
    History/
    Shared/
  Repositories/
    AIChat/
    History/
    Shared/
```

说明：

- `Application` 用于承接业务流程编排
- `Presentation/Shared` 用于承接图表组件和公共 UI 支撑代码
- 原 `Views` 目录已经并回 `Presentation`
- 这套结构已经比较接近 Android / Web 的 feature + layer 镜像母版

## 已完成的 use case

### AIChat

- `LoadTemplateUseCase`
- `LoadHistoryDetailUseCase`
- `SendFunctionMessageUseCase`
- `LoadChartDataUseCase`
- `StreamAIResponseUseCase`

### History

- `LoadHistoryPageUseCase`
- `DeleteHistoryUseCase`
- `DeleteAllHistoryUseCase`

## 已完成的接入

当前已经接到 `ViewModel` 的有：

- `AIChatViewModel.loadTemplate`
- `AIChatViewModel.getHistoryDetail`
- `AIChatViewModel.sendFunctionMessage`
- `AIChatViewModel.getChartData`
- `AIChatViewModel.sendStreamMessage`
- `HistoryViewModel.getDataList`
- `HistoryViewModel.deleteHistory`
- `HistoryViewModel.deleteAllHistory`

## 为什么这些逻辑值得做成 use case

这批逻辑都有同一个特征：

- 不只是单纯调一次 repository
- 又不应该继续留在 `ViewModel` 里

例如：

- `LoadHistoryPageUseCase`
  - 分页请求
  - 分组
  - 合并分页结果
  - 生成 section view data
- `DeleteHistoryUseCase`
  - 删除远端
  - 计算本地删除后的新列表状态
- `SendFunctionMessageUseCase`
  - 发送函数消息
  - 解析 `FunctionModel`
  - 判断是 intent、chart 请求还是失败
- `LoadChartDataUseCase`
  - 请求图表数据
  - 调用 builder
  - 统一输出图表结果

这些都属于 application 层的“业务流程编排”，不是纯数据访问，也不是纯 UI 状态。

## 当前设计原则

当前阶段，use case 应该只做这些事：

1. 编排 repository / helper / builder
2. 输出更稳定的业务结果
3. 作为 `ViewModel` 的直接依赖入口

当前阶段仍然不建议 use case 做这些事：

- 直接持有 UIKit 类型
- 直接回调 controller
- 直接做路由
- 重复封装只是透传 repository 的空壳

## 当前价值

这轮 use case 化已经带来几个很具体的结果：

- `ViewModel -> UseCase -> Repository` 依赖方向已经建立
- `History` 已形成完整样板
- `AIChat` 的主链路也已经具备可复制母版
- Android / Web 后续不需要直接照抄 iOS `ViewModel`

## 当前测试覆盖

当前 application 层和相关边界已经有第一轮自动化保护，主要覆盖：

- `LoadTemplateUseCase`
- `LoadHistoryDetailUseCase`
- `SendFunctionMessageUseCase`
- `LoadChartDataUseCase`
- `StreamAIResponseUseCase`
- `LoadHistoryPageUseCase`
- `DeleteHistoryUseCase`
- `DeleteAllHistoryUseCase`
- `SendLikeFeedbackUseCase`

同时还覆盖了与 use case 强关联的关键行为：

- `AIChatIntentResolver`
- `FunctionResponseDTO`
- `HistoryListViewDataBuilder`
- `AIChatViewModel` 的模板/历史/函数/图表失败回调
- `AIChatViewModel` 的流式消息链
- `HistoryViewModel` 的失败加载和清空状态

这说明当前 `module-ai` 的 use case 层已经不是“只有目录和命名”，而是已经有可回归的最小保护网。

当前仍未完全覆盖的方向包括：

- 更多 repository 抛错组合
- `ViewModel` 更细的状态切换顺序
- 更完整的 stream edge case
- application result model 的契约级测试

## 当前还没完全做完的点

现在不再是“要不要加 use case”的问题，而是：

- `ViewModel` 里剩余少量 repository 直连点是否继续收口
- use case 的 result model 是否要再中性化
- `Presentation/Shared` 里哪些 helper 未来还要继续下沉
- Android / Web 要按哪套稳定契约来镜像

## 对 ViewModel 的当前要求

当前 `ViewModel` 的合理状态是：

- 持有 use case
- 负责页面状态和交互入口
- 不再自己编排主要业务流程

但当前仍不要求：

- 完全不碰 repository
- 一次性去掉所有 async 逻辑
- 一次性上完整 clean architecture 模板

## 一句话结论

`module-ai` 的 use case 层已经完成第一轮落地。后续重点应该从“补更多 use case”切到“稳定 application 层契约和多端镜像规则”。
