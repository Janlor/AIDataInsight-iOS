# AIDataInsight HarmonyOS NEXT

AIDataInsight HarmonyOS NEXT 是多端契约的下一阶段实现端。当前目录已跑通学习项目所需的主链路，并保留后续 Web 端生成可复用的契约边界。

## 当前状态

- 已建立 `app-harmony` 源码骨架。
- 已固定并生成 ArkTS contract models。
- 已补最小 contract mapper 和 golden fixture 单测。
- 已建立 `core:model`、`core:network`、`core:account`、`core:ui` 基础层。
- 已接入 Login Apifox mock 登录、隐私入口和启动自动登录导航。
- 已补 AIHome 壳层，承接 AIChat 主入口、History 面板和 Setting route。
- 已补 Setting / Privacy 链路，支持账户信息、隐私政策和退出登录。
- 已补 History Apifox mock 列表链路，支持分组、无感刷新和选择会话。
- 已补 AIChat Apifox mock 链路，支持模板问题、输入发送、`/stream` 返回文本展示、图表 fallback 和反馈状态。
- 已建立 App 路由、Core、Feature 的命名边界。
- 第一版面向学习项目和 Apifox mock 环境，不连接真实生产后端。
- 阶段 10 工程收尾已完成；真机能力、性能和发布链路仍待设备侧验证。

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
    │   ├── network         # Apifox mock baseURL、真实 HTTP transport、响应外壳、错误处理
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

`scripts/generate-cross-platform-contracts.sh` 已支持输出 ArkTS contract models：

```text
app-harmony/entry/src/main/ets/contracts/generated/ContractModels.ets
```

不要手改生成文件。模型不对时先改 `docs/cross-platform/contracts`，再运行生成脚本。

## 开发规则

- 先读 `docs/ai-generation-guide.md`。
- 再读 `docs/architecture/harmonyos-next-implementation-plan.md`。
- HarmonyOS NEXT 工程说明优先读 `app-harmony/README.md` 和 `app-harmony/docs/module-boundaries.md`。
- HarmonyOS NEXT 只能从已验证契约生成，不能从 iOS UIKit 或 Android Compose 页面反推。
- ArkTS 不是 TypeScript，不能直接复制 Web 代码。
- 没有真机时，必须说明真机能力、性能和发布链路未验证。

## 验证

常用收尾验证：

```sh
ruby scripts/validate-cross-platform-contracts.rb
env DEVECO_SDK_HOME=/Applications/DevEco-Studio.app/Contents/sdk NODE_HOME=/Applications/DevEco-Studio.app/Contents/tools/node /Applications/DevEco-Studio.app/Contents/tools/hvigor/bin/hvigorw --mode module -p module=entry assembleHap --no-daemon
```

## 已知边界

- 当前接入的是 Apifox mock URL，不是真实生产服务。
- `/stream` 当前按完整响应解析 `data:` 内容并一次性展示，不声明已验证 HarmonyOS NetworkKit 实时 SSE / `dataReceive` 打字机能力。
- 签名、发布、性能、设备兼容和真机日志仍需在 DevEco / 设备环境下单独验证。
