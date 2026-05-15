# AIDataInsight HarmonyOS NEXT

AIDataInsight HarmonyOS NEXT 是多端契约的下一阶段实现端。当前目录先建立工程骨架和代码生成目标路径，业务实现后续按契约逐步补齐。

## 当前状态

- 已建立 `app-harmony` 源码骨架。
- 已固定 ArkTS contract models 的目标路径。
- 已建立 App 路由、Core、Feature 的命名边界。
- Login、AIHome、Setting、Privacy、History、AIChat 目前是占位页面。
- 第一版面向学习项目和 mock 环境，不连接真实生产后端。

## 目录结构

```text
app-harmony
├── README.md
├── docs
└── entry/src/main/ets
    ├── app
    │   ├── navigation      # AppDestination、导航状态和路由意图适配
    │   └── pages           # AIHome 等 App 壳页面
    ├── contracts/generated # 后续由契约生成的 ArkTS models
    ├── core
    │   ├── model           # 本端模型聚合入口
    │   ├── network         # mock baseURL、请求、响应外壳、错误处理
    │   ├── account         # session store、自动登录判断
    │   └── ui              # 主题、背景、安全区、通用组件
    └── feature
        ├── login
        ├── setting
        ├── privacy
        ├── history
        └── ai_chat
```

## 生成目标

后续扩展 `scripts/generate-cross-platform-contracts.sh` 时，ArkTS contract models 输出到：

```text
app-harmony/entry/src/main/ets/contracts/generated/ContractModels.ets
```

不要手改生成文件。模型不对时先改 `docs/cross-platform/contracts`。

## 开发规则

- 先读 `docs/ai-generation-guide.md`。
- 再读 `docs/architecture/harmonyos-next-implementation-plan.md`。
- HarmonyOS NEXT 只能从已验证契约生成，不能从 iOS UIKit 或 Android Compose 页面反推。
- ArkTS 不是 TypeScript，不能直接复制 Web 代码。
- 没有真机时，必须说明真机能力、性能和发布链路未验证。

## 下一步

阶段 2：扩展契约生成脚本，输出 ArkTS contract models，并用 golden fixtures 做最小 mapper 验证。
