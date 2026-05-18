# AIDataInsight Web 端执行计划

## 文档定位

这份文档用于指导 AIDataInsight 在 iOS、Android、HarmonyOS NEXT 主要功能完成后，开始 Web 端开发。

Web 端不是从移动端页面反推出来的新实现，而是基于现有跨平台契约、领域模型、接口规则和已完成端侧经验，独立完成 Web 工程、业务链路和桌面交互体验。

当前源事实包括：

- `app-web/src/contracts/generated/models.ts`
- `docs/cross-platform/contracts/api/openapi.yaml`
- `docs/cross-platform/contracts/usecases/*.usecases.yaml`
- `docs/cross-platform/contracts/ui-state/*.yaml`
- `docs/cross-platform/contracts/fixtures/**/*`
- `docs/cross-platform/api-contract.md`
- `docs/cross-platform/domain-models.md`
- `docs/cross-platform/design-tokens.md`

如果 Web 端开发过程中发现模型、接口、用例输出或 UI state 缺失，应先更新 `docs/cross-platform/contracts`，再运行契约生成脚本，不应直接在 Web 端临时补一套隐性规则。

## 当前状态

当前 Web 端状态：

- 已完成 `app-web` Next.js App Router / React / TypeScript / Tailwind CSS 工程
- 已接入契约生成模型 `app-web/src/contracts/generated/models.ts`
- 已完成 Apifox mock / local mock / dev / test / pre / prod 环境矩阵
- 已完成网络层、登录态、页面路由、AI Chat、History、Setting、Privacy 和多语言
- 已建立 Vitest 单元测试、Playwright E2E 和 Web CI 质量门禁

当前其他端状态：

- iOS 主要功能已完成
- Android 主要功能已完成
- HarmonyOS NEXT 主要功能已完成
- 跨平台契约、API 规则、领域模型和 UI state 已具备作为 Web 起点的基础

因此 Web 端后续工作的重点不是重新探索业务，而是：

- 继续复用跨平台契约并避免端侧漂移
- 接入真实 DEV / TEST / PRE / PROD 后端环境
- 扩大 runtime validation 和错误态覆盖
- 打磨桌面工作台体验
- 保持 Web CI 和 E2E 回归保护

## 收尾状态

截至 2026-05-18，Web 第一版主功能已完成，当前进入收尾和联调准备阶段。

已完成：

- 工程脚手架、路由、布局、设计 token 和深色模式
- HTTP client、response envelope、session store、`401` / `402` refresh 行为
- 登录、自动登录、退出登录和用户信息
- 类 ChatGPT 左侧历史会话布局、New Chat、历史恢复和历史删除
- AI Chat 模板问题、消息发送、SSE 流式响应、图表 fallback 和反馈
- Setting、Privacy、契约内容读取和简体中文 / English 国际化
- Apifox mock 与 local mock 双模式支持
- 单元测试、构建检查和 Playwright E2E 主流程

仍建议在真实联调阶段继续补齐：

- 真实 DEV / TEST / PRE / PROD host 与部署平台环境变量
- 更完整的 runtime validation
- 真实接口错误态、超时态、空状态和性能指标

## 总体原则

### 契约先行

Web 端所有领域模型、接口字段、用例输出和关键 UI state 以 `docs/cross-platform/contracts` 为准。

禁止直接从 iOS UIKit、Android Compose 或 HarmonyOS ArkUI 页面结构反推 Web 领域模型。

### UI 独立实现

Web 端不追求与移动端 UI 像素级一致。

Web 第一版应优先面向桌面工作台体验：

- 清晰导航
- 稳定对话区域
- 高效历史记录访问
- 图表和结果区域适合大屏查看
- 响应式兼容平板和手机访问

### 行为跨端一致

以下规则必须与其他端保持一致：

- API path、method、参数名
- 统一响应外壳
- 业务错误码保留
- `401` session 失效处理
- `402` token refresh 后重试
- 登录成功后的 session 归一化
- DTO snake_case 不泄漏到领域层和 UI 层

### 分阶段交付

Web 端不应一次性追求完整大而全。

推荐先完成可运行工程和登录闭环，再推进 AI Chat、History、Setting、Privacy 等业务模块。

## 推荐技术栈

```text
语言：TypeScript
框架：Next.js App Router + React
数据请求：TanStack Query
运行时校验：Zod
样式：Tailwind CSS 或 CSS Modules
图表：ECharts
单元测试：Vitest
组件测试：React Testing Library
端到端测试：Playwright
契约来源：docs/cross-platform/contracts
生成模型：app-web/src/contracts/generated/models.ts
```

样式方案在第一阶段应固定一种，不建议 Tailwind CSS 和 CSS Modules 大面积混用。若没有额外约束，优先选择更适合快速搭建一致设计系统的 Tailwind CSS。

## 推荐目录结构

Web 工程建议继续放在 `app-web` 下。

```text
app-web/
  app/
    (auth)/
      login/
    (main)/
      ai/
      history/
      setting/
      privacy/
    layout.tsx
    page.tsx
  src/
    contracts/
      generated/
    domain/
    data/
      http/
      account/
    features/
      login/
      ai-chat/
      history/
      setting/
      privacy/
    components/
    state/
    lib/
    testing/
```

目录职责：

- `app/`：Next.js App Router、布局、页面入口、路由分组
- `src/contracts/generated/`：契约生成代码，只由脚本生成
- `src/domain/`：领域模型、业务错误、平台无关类型
- `src/data/http/`：HTTP client、response envelope、token refresh
- `src/data/account/`：session store、account repository
- `src/features/*/`：各业务模块的 repository、use case、hooks、components
- `src/components/`：跨模块 UI 组件
- `src/state/`：全局状态或轻量 store
- `src/lib/`：通用工具
- `src/testing/`：测试工具、mock server、fixtures adapter

## 阶段 0：基线确认

目标：明确第一版 Web 范围和验收标准。

任务：

1. 复核跨平台契约：
   - `docs/cross-platform/contracts/api/openapi.yaml`
   - `docs/cross-platform/contracts/usecases/*.usecases.yaml`
   - `docs/cross-platform/contracts/ui-state/*.yaml`
   - `docs/cross-platform/contracts/fixtures/**/*`
2. 确认第一版功能范围：
   - 登录
   - 自动登录
   - 退出
   - AI 首页
   - AI 对话
   - 历史记录
   - 设置
   - 隐私协议
3. 建立 Web 端验收基线：
   - 本地可启动
   - DEV / PRE / PROD host 可切换
   - 契约生成可重复执行
   - 登录态、请求错误、token refresh 行为与其他端一致

交付物：

- Web 第一版功能清单
- Web 验收标准
- 契约缺口清单

## 阶段 1：工程脚手架

目标：让 `app-web` 从契约模型目录变成可运行 Web 应用。

任务：

1. 初始化 Next.js App Router + TypeScript 工程。
2. 保留并接入 `src/contracts/generated/models.ts`。
3. 配置基础命令：
   - `dev`
   - `build`
   - `start`
   - `lint`
   - `typecheck`
   - `test`
4. 建立环境配置：
   - `NEXT_PUBLIC_API_BASE_URL`
   - `APP_ENV=dev/pre/prod`
5. 建立基础路由：
   - `/login`
   - `/ai`
   - `/history`
   - `/setting`
   - `/privacy`
6. 建立主布局：
   - 顶层 shell
   - 主导航
   - 登录态守卫
   - loading / error / empty 基础状态
7. 接入设计 token：
   - 颜色
   - 字号
   - 间距
   - 圆角
   - 暗色模式如暂不支持，应明确标记为后续项

交付物：

- `npm run dev` 可启动
- `npm run typecheck` 可通过
- 登录页和主页面路由可访问
- 基础布局和导航可用

## 阶段 2：网络层与账户体系

目标：先把跨端最容易漂移的 session 和错误处理做稳。

任务：

1. 实现 HTTP client：
   - 统一 base URL
   - 统一 header 注入
   - GET query 编码
   - JSON body 编码
   - 请求超时
   - 请求取消
2. 实现 response envelope 解析：
   - `msg`
   - `code`
   - `data`
   - `trace`
   - `tid`
3. 实现错误模型：
   - `unknown`
   - `dataFormat`
   - `server(code, msg)`
4. 实现 session store：
   - `accessToken`
   - `refreshToken`
   - `orgId`
   - `userInfo`
5. 实现 token refresh：
   - 命中 `402` 时尝试 refresh
   - refresh 成功后重试原请求
   - refresh 失败或命中 `401` 时清空 session
   - 清空 session 后统一跳转登录
6. 实现账户接口：
   - `POST /oauth2/login`
   - `GET /oauth2/refresh`
   - `GET /oauth2/logout`
   - `GET /oauth2/getUserInfo`

交付物：

- 登录成功后进入主页面
- 刷新浏览器后可恢复登录态
- 退出后清空 session 并回到登录页
- `401` / `402` 行为有测试覆盖

## 阶段 3：核心业务闭环

目标：优先完成用户最核心的一条使用路径。

推荐顺序：

1. Login
2. AI Home
3. AI Chat
4. History
5. Setting
6. Privacy

### AI Home

任务：

- 加载首页状态
- 展示入口卡片或功能入口
- 跳转 AI Chat
- 处理 loading / empty / error

交付物：

- 用户登录后可以进入 AI 首页
- 首页状态与跨平台 UI state 保持一致

### AI Chat

任务：

- 加载模板
- 创建或恢复会话
- 发送普通消息
- 发送 function message
- 展示流式响应
- 加载图表数据
- 展示图表 fallback
- 发送点赞或反馈
- 处理中断、失败、重试

交付物：

- 用户可以发起对话并看到响应
- 用户可以查看图表类结果
- 会话失败可以重试
- 流式响应不会破坏页面布局

### History

任务：

- 分页加载历史记录
- 删除单条历史
- 清空历史
- 从历史记录进入详情对话
- 处理空历史状态

交付物：

- 用户可以查看历史列表
- 用户可以恢复历史对话
- 删除和清空行为与其他端一致

### Setting

任务：

- 展示用户信息
- 展示应用设置
- 提供退出登录入口
- 保留后续扩展空间

交付物：

- 用户可以查看设置页
- 用户可以稳定退出登录

### Privacy

任务：

- 展示隐私协议内容
- 支持从登录页或设置页访问
- 如协议内容来自远端，按契约接入 repository

交付物：

- 用户可以访问隐私协议页面

## 阶段 4：契约生成与一致性校验

目标：确保 Web 不成为手写漂移的一端。

任务：

1. 固化生成流程：
   - 使用 `scripts/generate-cross-platform-contracts.sh`
   - 输出到 `app-web/src/contracts/generated`
2. 固化校验流程：
   - 使用 `scripts/validate-cross-platform-contracts.sh`
   - Web typecheck 依赖 generated models
3. 为接口 DTO 增加 runtime validation。
4. 基于 fixtures 建立测试：
   - 登录响应
   - refresh token 响应
   - 用户信息响应
   - AI Home 状态
   - AI Chat 响应
   - History 响应
   - error envelope
5. 建立 mapper 测试：
   - API DTO -> domain model
   - contract UI state -> Web view state
   - snake_case -> camelCase

交付物：

- 契约变更后 Web 可自动发现类型或测试问题
- UI 层不直接依赖后端 snake_case DTO
- 核心 fixtures 在 Web 测试中可复用

## 阶段 5：Web 体验与适配

目标：让 Web 端成为适合桌面使用的工作台，而不是移动端页面放大版。

任务：

1. 桌面优先布局：
   - 左侧导航
   - 主工作区
   - 对话区
   - 历史侧栏或历史页面
2. 响应式适配：
   - 桌面完整体验
   - 平板可用
   - 手机可访问
3. AI Chat 体验：
   - 消息列表稳定滚动
   - 输入框快捷提交
   - 流式响应期间布局稳定
   - 图表区域稳定渲染
   - 错误可重试
4. 状态体验：
   - loading
   - empty
   - error
   - offline
   - timeout
   - session expired
5. 可访问性：
   - 键盘可操作
   - 表单 label 明确
   - 焦点状态清晰
   - 颜色对比度可接受

交付物：

- 桌面主流程体验可用
- 平板和手机视口没有明显布局错乱
- Playwright 覆盖关键页面截图或主流程检查

## 阶段 6：测试与发布准备

目标：Web 端具备可持续迭代和上线准备。

测试分层：

- Unit：domain mapper、use case、error handling
- Component：登录表单、对话输入、历史列表、设置页
- Integration：HTTP client + mock server
- E2E：登录、对话、历史、退出
- Contract：fixtures 与 generated models 校验

发布准备：

1. 配置构建命令：
   - `npm run build`
   - `npm run start`
2. 增加 CI 检查：
   - install
   - lint
   - typecheck
   - test
   - build
3. 配置部署环境：
   - DEV
   - PRE
   - PROD
4. 明确运行时能力：
   - 日志
   - 错误上报
   - API trace / tid 展示或采集
   - 基础性能指标

交付物：

- Web 可构建
- Web 可部署到 DEV / PRE
- CI 能阻止类型、测试和构建回归
- 关键链路有 E2E 保护

## 里程碑

| 里程碑 | 目标 | 结果 |
| --- | --- | --- |
| M1 | 工程可运行 | 已完成：Next.js 骨架、路由、样式、环境配置 |
| M2 | 登录闭环 | 已完成：login / refresh / logout / session restore |
| M3 | AI 主流程 | 已完成：AI 首页、对话、流式响应、历史详情 |
| M4 | 辅助模块 | 已完成：history list、setting、privacy、i18n、dark mode |
| M5 | 质量加固 | 已完成：contract fixtures tests、E2E、构建、Web CI |
| M6 | Web Beta | 准备中：接入真实 DEV / PRE host 后进入联调和体验打磨 |

## 第一批建议任务

Web 端启动时，第一批任务应控制在工程基础和登录闭环，不建议一开始同时展开所有页面。

建议顺序：

1. 初始化 `app-web` Next.js 工程。
2. 保留并接入现有 generated models。
3. 增加环境配置和基础路由。
4. 实现 HTTP client 和 response envelope。
5. 实现 session store。
6. 实现 login / refresh / logout。
7. 完成登录页到 AI 首页的最小闭环。
8. 为 `401` / `402` / response envelope 增加测试。

完成以上任务后，再进入 AI Chat 和 History 的业务开发。

## 风险与应对

### 契约缺失

风险：

- Web 开发时发现某些状态或字段只有移动端实现，没有沉淀到契约。

应对：

- 先更新 `docs/cross-platform/contracts`
- 再生成 Web models
- 最后实现 Web 页面和测试

### Token refresh 并发

风险：

- 多个请求同时遇到 `402` 时触发多次 refresh，导致 session 状态混乱。

应对：

- HTTP client 中实现 refresh single flight
- refresh 期间排队等待
- refresh 成功后统一重试

### Web UI 直接复制移动端

风险：

- 页面可用但不适合桌面使用，AI Chat 和 History 效率低。

应对：

- Web 端按桌面工作台设计
- 只复用业务规则和 UI state，不复用移动端布局

### DTO 泄漏到 UI

风险：

- 后端字段名和接口结构直接进入组件，后续契约变化成本变高。

应对：

- repository 层完成 DTO 到 domain model 的转换
- UI 只消费 view state
- mapper 测试覆盖 snake_case 到 camelCase

### 缺少真实后端环境

风险：

- Web 开发受阻于接口不可用或环境不稳定。

应对：

- 优先使用 contract fixtures 和 mock server
- DEV / PRE 联调作为阶段性交付
- 网络层和业务 mapper 可在 mock 下独立验证

## 验收清单

Web Beta 进入联调前至少满足：

- `npm run typecheck` 通过
- `npm run test` 通过
- `npm run build` 通过
- 登录 / 自动登录 / 退出可用
- `401` / `402` 行为符合跨端规则
- AI 首页可访问
- AI Chat 主流程可用
- History 列表和详情可用
- Setting 和 Privacy 可访问
- API response envelope 解析有测试
- contract fixtures 已被 Web 测试消费
- 桌面和平板视口无明显布局错乱
