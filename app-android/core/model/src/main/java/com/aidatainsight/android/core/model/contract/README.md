# 契约模型

`ContractModels.kt` 由 `docs/cross-platform/contracts` 生成。

不要手改生成的契约模型。如果模型需要调整，先更新契约包，再在仓库根目录重新生成：

```sh
scripts/generate-cross-platform-contracts.sh
```

Feature 模块应该把这些 contract / application models 映射成本端 Compose UI state，不要复制 iOS UIKit 的 view data models。
