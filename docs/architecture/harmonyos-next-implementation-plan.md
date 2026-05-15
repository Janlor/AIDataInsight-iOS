# HarmonyOS NEXT 适配执行清单

这份文档用于给 AI 在中断后恢复 HarmonyOS NEXT 适配任务时读取。目标是避免上下文过长后忘记当前阶段、顺序和边界。

## 当前目标

当前多端优先级是：

```text
iOS -> Android -> HarmonyOS NEXT -> Web -> 其它候选端
```

iOS 和 Android 已完成主要功能。HarmonyOS NEXT 是下一阶段目标，第一版仍面向学习项目和 mock 环境，不连接真实生产后端。

## 总原则

- 先读 `docs/ai-generation-guide.md` 和 `docs/cross-platform/contracts/README.md`。
- HarmonyOS NEXT 只能从已验证契约生成，不能从 iOS UIKit 或 Android Compose 页面反推。
- 先做可编译、可运行、可验证的最小链路，再追 UI 还原。
- 没有真机时，必须说明真机能力、性能和发布链路未验证。
- ArkTS 不是 TypeScript，不能直接复制 Web 代码。

## 执行阶段

### 0. 环境与边界

- 安装 DevEco Studio。
- 创建空 HarmonyOS NEXT 工程并跑通 Hello World。
- 确认包名、应用名、SDK/API 版本、模拟器或真机验证方式。
- 明确第一版只使用 mock 环境。

### 1. 工程骨架

- 新建 `app-harmony`。
- 建立基础目录和命名边界：
  - `app`
  - `core/model`
  - `core/network`
  - `core/account`
  - `core/ui`
  - `feature/login`
  - `feature/setting`
  - `feature/privacy`
  - `feature/history`
  - `feature/ai-chat`
- 先建 Login、AIHome、Setting、Privacy、History、AIChat 占位页面和路由。

### 2. 契约生成

- 扩展 `scripts/generate-cross-platform-contracts.sh`，增加 ArkTS contract models 输出。
- 建议目标路径：

```text
app-harmony/entry/src/main/ets/contracts/generated/ContractModels.ets
```

- 先只生成模型，不生成页面。
- 运行 contract validation。

### 3. Mapper Tests / Golden Fixtures

- 优先复用现有 `docs/cross-platform/contracts/fixtures`。
- 先覆盖：
  - `AccountSession`
  - `SettingSnapshot`
  - `HistoryRecord`
  - `AIChatMessage`
  - `FunctionName -> FunctionArguments`
  - `ChartPayload`

### 4. Core 层

- `core:model`：接 generated models。
- `core:network`：封装 mock baseURL、请求、响应外壳、错误处理。
- `core:account`：登录态、session store、自动登录判断。
- `core:ui`：颜色、背景、安全区、通用按钮、列表样式。

### 5. Login

- 按契约还原登录页。
- 接 mock 登录接口。
- 保存 session。
- 启动时自动登录进入 AIHome。
- Privacy 链接先打开本地 HTML 或内置静态页面。

### 6. AIHome

- 登录成功后进入 AIHome。
- AIHome 管理：
  - AIChat 主内容
  - History 面板或页面
  - Setting 入口
  - 新会话
- 先保证状态切换语义，不急着完整还原动画。

### 7. Setting / Privacy

- Setting 展示账户信息、隐私政策、版本号、退出登录。
- 退出登录清 session，并替换回 Login。
- Privacy 先保证可打开、可返回、中文可显示。

### 8. History

- 接历史列表 mock 接口。
- 分组规则沿用契约：今天、昨天、其它。
- 有数据时无感刷新。
- 选择历史后关闭 History，让现有 AIChat 加载该会话，不新开 Chat 页面。

### 9. AIChat

- 加载模板问题。
- 实现输入、发送、清空、新会话。
- 接流式 mock。
- 图表 fallback 文案固定为：

```text
数据分析还在测试阶段，很快就能上线，敬请期待！
```

- 再补图表和反馈按钮。

### 10. 收尾

- 补 `app-harmony/README.md`。
- 更新 `docs/ai-generation-guide.md` 中 HarmonyOS NEXT 的实际工程路径。
- 更新 `docs/cross-platform/change-log.md`。
- 运行 contract validation。
- 做工程卫生。

## 下一步建议

第一步先做：

```text
创建 app-harmony 工程骨架 + README + 空页面路由 + generated models 目标路径设计
```

先固定 AI 以后往哪里生成代码，再开始生成业务。
