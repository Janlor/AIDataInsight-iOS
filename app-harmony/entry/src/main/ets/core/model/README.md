# core/model

聚合契约生成模型和本端轻量类型入口。不要依赖 ArkUI 页面。

当前入口：

- `ContractModelExports.ets`：从 `contracts/generated/ContractModels.ets` re-export 跨端模型，业务代码优先从这里引入。

规则：

- 不手改 generated models。
- 不在 `core:model` 引入页面、组件、网络请求或持久化实现。
