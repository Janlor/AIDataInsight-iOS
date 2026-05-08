# AIDataInsight 多端适配建议与技术栈

## 文档目的

这份文档明确 AIDataInsight 的端侧支持顺序、技术栈选择和暂缓范围。

当前真实目标不是同时推进所有端，而是：

1. iOS
2. Android
3. Web
4. 鸿蒙、macOS、Windows 等候选端按条件再评估

---

## 一、端侧优先级

### P0：iOS

当前状态：

- 主要功能已完成
- 已完成一轮跨平台契约化准备
- UIKit App 当前可通过 iPadOS 兼容模式运行在 macOS 上

建议：

- 短期继续保留 UIKit，不做一次性 SwiftUI 重写
- Application / Domain 层继续保持平台无关
- 等 Android / Web 主链路跑通后，再考虑 SwiftUI 化
- SwiftUI 化后再评估 macOS 原生 target

技术栈：

```text
语言：Swift
UI：UIKit，后续可渐进式引入 SwiftUI
异步：async/await + AsyncThrowingStream
架构：App Shell + Domain + Application + Repositories + Presentation
网络：RequestDescriptor / NetworkExecutor
测试：Swift Testing / XCTest + contract fixtures
```

### P1：Android

当前状态：

- 已有 `app-android` 脚手架
- 已有 `core:model`、`feature/*` 基础模块
- 已能从 contract 生成 Android contract models

建议：

- Android 是第二优先级
- 先做数据层、repository、use case、UI state
- Compose UI 可以先做低保真版本
- 没有 Android 真机时，先依赖编译、单测、模拟器和 contract fixtures

技术栈：

```text
语言：Kotlin
UI：Jetpack Compose
导航：Navigation Compose
异步：Coroutines + Flow
序列化：Kotlinx Serialization
网络：Ktor Client 或 Retrofit
架构：core:model / core:network / core:account / feature:* 分层
测试：JUnit + kotlinx-coroutines-test + contract fixtures
生成模型：app-android/core/model/.../contract/ContractModels.kt
```

### P2：Web

当前状态：

- 已有 `app-web/src/contracts/generated/models.ts`
- 尚未建立完整 Web 工程

建议：

- Web 是第三优先级
- 先用契约生成 TypeScript models
- 再搭 Next.js 工程
- 页面 UI 不从 iOS 页面照抄，先保证业务链路和 contract tests

技术栈：

```text
语言：TypeScript
框架：Next.js App Router + React
数据请求：fetch 封装或 TanStack Query
图表：ECharts 或 AntV，第一版建议 ECharts
运行时校验：Zod 可选
测试：Vitest + Testing Library + Playwright 可选
生成模型：app-web/src/contracts/generated/models.ts
```

### P3：鸿蒙 HarmonyOS / OpenHarmony

当前状态：

- 尚未开始实现
- 没有鸿蒙真机
- 需要额外学习 DevEco Studio、ArkTS、ArkUI、Ability、路由、包结构、签名和调试流程

建议：

- 暂时不要把鸿蒙列为和前三端同阶段的强目标
- iOS / Android / Web 主链路完成后再评估
- 如果后续要做，先从“契约模型 + 静态页面 + mock 数据”开始
- AI 可以辅助生成鸿蒙代码，但需要更严格的人工审核和官方文档对照

推荐技术栈：

```text
语言：ArkTS
UI：ArkUI 声明式 UI
IDE：DevEco Studio
架构：contracts -> domain models -> data service -> usecase -> page state -> ArkUI page
网络：鸿蒙官方网络能力或项目统一封装
状态：ArkUI 状态管理机制
测试：DevEco Studio 单元测试 / UI 测试 / 模拟器验证
生成策略：先生成 contract models 和 mapper，再生成 ArkUI 页面
```

AI 生成鸿蒙代码的主要风险：

- ArkTS 和 TypeScript 相似但不等同，AI 容易写出“像 TS 但不能编译”的代码
- ArkUI 装饰器、状态管理、生命周期和 React / SwiftUI / Compose 不完全等价
- 工程配置、模块配置、权限、签名、依赖声明容易漏
- 官方 API 版本变化会影响可用性
- 没有真机时，设备能力、系统服务、性能和发布链路都只能低置信度判断

适配策略：

1. 先只生成 `contracts` 对应的 ArkTS 类型
2. 用 fixtures 做纯函数 mapper 测试
3. 做 AI Chat / History 的静态页面
4. 再接 repository 和网络
5. 最后接登录、token refresh、SSE / streaming、设备能力和发布链路

### P4：macOS

当前状态：

- 现有 iOS App 已能通过 iPadOS 兼容模式运行在 macOS
- 这已经是一个低成本 macOS 覆盖方式

建议：

- 短期不单独做 macOS target
- iOS 继续作为主 App
- 后续如果 UIKit 逐步迁移 SwiftUI，再评估 macOS 原生支持

可选技术路线：

```text
短期：iPadOS 兼容模式运行在 macOS
中期：SwiftUI 组件渐进替换 UIKit 页面
长期：SwiftUI + multiplatform target，必要时加少量 AppKit 适配
```

### P5：Windows Desktop

当前状态：

- 没有明确支持计划
- 没有 Windows 设备测试
- 当前业务不需要优先做 Windows 客户端

建议：

- 暂不进入开发计划
- 如果未来要支持 Windows，优先考虑 Web / PWA 或 Tauri / Electron
- 除非有明确企业桌面部署需求，否则不值得早期投入

候选技术：

```text
优先：Web / PWA
可选：Tauri + Web 前端
可选：Electron
低优先：原生 Windows / WinUI
```

---

## 二、推荐阶段划分

### 阶段 1：iOS 稳定为参考实现

目标：

- iOS 功能稳定
- Application / Domain 不泄漏 UIKit
- contract tests 覆盖核心业务规则

### 阶段 2：Android 跑通主链路

目标：

- 登录 / 会话
- AI Chat
- History
- Setting / Privacy 基础入口
- contract models 和 fixtures 对齐

### 阶段 3：Web 跑通主链路

目标：

- 使用生成 TypeScript models
- 实现 repository / usecase / UI state
- AI Chat 和 History 可用
- 图表基于 `ChartPayload`

### 阶段 4：评估鸿蒙

进入条件：

- iOS / Android / Web 三端主链路完成
- contract tests 稳定
- 有 DevEco Studio 环境
- 最好能获得至少一台鸿蒙真机，或确认模拟器足够覆盖当前功能

先做：

- contract models
- mock repository
- AI Chat / History 静态页面

后做：

- 登录
- token refresh
- SSE / streaming
- 发布和真机能力

### 阶段 5：评估 macOS / Windows

进入条件：

- 确认有真实桌面端业务需求
- Web / PWA 不能满足
- 有测试设备或可用测试环境

---

## 三、没有真机时的验证策略

### Android

可以先依赖：

- Gradle 编译
- JVM 单元测试
- Android 模拟器
- contract fixtures

需要真机再确认：

- 性能
- 输入法
- 系统权限
- 后台行为
- 推送、分享、文件、相册等系统能力

### 鸿蒙

可以先依赖：

- DevEco Studio 编译
- DevEco 模拟器
- ArkTS 单元测试
- contract fixtures

需要真机再确认：

- 系统权限
- 网络安全策略
- 性能和内存
- 多设备能力
- 发布、签名、审核链路

### Windows

如果未来走 Web / PWA：

- 可先用浏览器和 Playwright 测试

如果未来走 Electron / Tauri：

- 必须补 Windows 环境或 CI

---

## 四、契约和生成关系

前三端以及未来候选端都必须遵守：

```text
contracts -> generated models -> repository -> usecase -> UI state mapper -> UI
```

禁止：

- 从 iOS UIKit 页面反推 Android / Web / 鸿蒙领域模型
- 从 Compose / React / ArkUI 页面反推 API 参数
- 每端各自维护一套 `FunctionName -> FunctionArguments` 映射
- 让 UI 直接解析后端 DTO

---

## 五、当前建议结论

当前最稳妥的端侧策略是：

```text
P0 iOS：继续稳定和契约化
P1 Android：第二优先级，先跑通主链路
P2 Web：第三优先级，先跑通主链路
P3 鸿蒙：候选端，等前三端后评估
P4 macOS：短期靠 iPadOS 兼容模式，SwiftUI 化后再看
P5 Windows：暂不规划，未来优先 Web / PWA
```

这条路线最符合当前约束：

- 你使用 Mac 开发
- iOS 已经可用
- Android / Web 是明确目标
- 鸿蒙和 Windows 暂无真机
- token 和时间预算有限
- 项目已经进入“契约驱动多端生成”的路线

---

## 六、参考资料

- OpenHarmony ArkUI / ArkTS UI 开发概览：`https://gitee.com/openharmony/docs/blob/ca6c3667fc6aec1ef95fc7438d8de4fd3b552d68/en/application-dev/ui/arkts-ui-development-overview.md`
- 华为开发者联盟 DevEco Studio：`https://developer.huawei.com/consumer/en/deveco-studio/`
- 华为开发者联盟 ArkTS：`https://developer.huawei.com/consumer/cn/arkts/`
- 华为开发者联盟 ArkUI：`https://developer.huawei.com/consumer/cn/arkui/`

