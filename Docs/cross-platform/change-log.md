# Cross-Platform Change Flow

## 文档目的

这份文档不只是记录“改了什么”。

它更重要的作用是固定一条流程：

- 任何一端发生修改时
- 先判断这次修改属于哪一类
- 再决定要同步到哪些端
- 最后决定更新顺序

这份文档服务于当前目标：

- 设计一套稳定领域模型
- 让 AI 稳定地产生 iOS / Android / Web / Desktop 四端实现

---

## 1. 核心原则

### 1.1 不追求四端代码相同

四端保持一致的，不是代码，而是：

- 领域模型
- API 契约
- 设计 token
- 关键交互规则
- 模块边界与命名

### 1.2 平台实现允许不同

以下内容不要求代码同步：

- UIKit / Compose / React / Desktop UI 代码
- 动画 API
- 布局系统
- 路由实现
- 各平台资源文件格式

### 1.3 先更新母版，再更新各端

如果变更影响跨端源事实，顺序必须是：

1. 先更新跨端母版文档
2. 再更新当前端实现
3. 再同步到其它端
4. 最后记录本次变更影响范围

---

## 2. 变更分类

任何改动先归类，不能直接开始“翻译到其它端”。

### 2.1 Domain Change

定义：

- 领域模型变化
- 业务规则变化
- 用例边界变化

常见例子：

- `SettingSnapshot` 新增字段
- 历史记录分组规则变化
- AI 意图识别规则变化

同步要求：

- 必须同步到四端

需要更新：

- `Docs/cross-platform/domain-models.md`
- `Docs/architecture/*` 中相关映射文档
- 各端 domain / usecase / viewmodel

### 2.2 API Contract Change

定义：

- 接口路径
- 请求参数
- 响应结构
- 错误码
- token refresh / session 规则

同步要求：

- 必须同步到四端

需要更新：

- `Docs/cross-platform/api-contract.md`
- 各端 network / repository / dto / mapper

### 2.3 Design Token Change

定义：

- 颜色
- 字体层级
- 间距规则
- 图表色板
- 图标语义
- 背景语义

常见例子：

- 品牌主色从绿色改为蓝色
- `tertiery` 修正为 `tertiary`
- App icon 风格变化

同步要求：

- 原则上同步到四端

需要更新：

- `Docs/cross-platform/design-tokens.md`
- iOS / Android / Web / Desktop theme token 映射

### 2.4 Interaction Rule Change

定义：

- 同一业务在各端应该保持一致的交互规则

常见例子：

- 登录成功后如何切主区
- 隐私协议何时弹出
- 历史删除后的刷新策略

同步要求：

- 必须同步到四端

需要更新：

- `Docs/cross-platform/interaction-rules.md`
- 各端 coordinator / route / state / event handling

### 2.5 Platform Implementation Change

定义：

- 只影响某一端的技术实现

常见例子：

- iOS 把约束改成新的布局方式
- Android 改 Compose 结构
- Web 改 CSS 实现

同步要求：

- 默认不同步到其它端

需要更新：

- 只更新当前端代码
- 如影响跨端理解，再补一条备注到相关文档

---

## 3. 同步决策表

| 变更类型 | 是否跨端同步 | 先改母版文档 | 是否改其它端代码 |
| --- | --- | --- | --- |
| Domain Change | 是 | 是 | 是 |
| API Contract Change | 是 | 是 | 是 |
| Design Token Change | 是 | 是 | 是 |
| Interaction Rule Change | 是 | 是 | 是 |
| Platform Implementation Change | 否 | 否 | 否 |

---

## 4. 标准流程

### 4.1 第一步：判断变更类型

任何提交前，先回答：

1. 这是 domain change 吗？
2. 这是 API change 吗？
3. 这是 design token change 吗？
4. 这是 interaction rule change 吗？
5. 如果都不是，它就是 platform implementation change

### 4.2 第二步：确定同步范围

按下列顺序判断：

- 只影响当前端
- 影响同类 feature
- 影响所有端共享规则

### 4.3 第三步：更新母版

如果属于跨端源事实，必须先更新：

- `Docs/cross-platform/design-tokens.md`
- `Docs/cross-platform/domain-models.md`
- `Docs/cross-platform/api-contract.md`
- `Docs/cross-platform/interaction-rules.md`

按实际类型选择，不要求每次都改全部。

### 4.4 第四步：更新当前端

先保证最先修改的那一端实现正确。

### 4.5 第五步：同步其它端

按这个顺序更稳：

1. Android
2. Web
3. Desktop

原因：

- 当前 iOS 是结构母版
- Android 与 iOS 分层映射最直接
- Web 和 Desktop 更适合在规则稳定后补齐

### 4.6 第六步：记录变更

每次跨端变更，至少记录：

- 来源提交
- 变更类型
- 影响范围
- 已同步端
- 待同步端

---

## 5. 变更记录模板

每次跨端变更，追加一条记录。

```md
## YYYY-MM-DD - Short Title

- Source:
  - commit: `abcdef0`
  - primary platform: `iOS`
- Change type:
  - `Design Token Change`
- Affected source of truth:
  - `Docs/cross-platform/design-tokens.md`
- Impact:
  - `accent.primary`
  - `background.vc`
  - `chart.blue`
- Synced:
  - [x] iOS
  - [x] Android
  - [ ] Web
  - [ ] Desktop
- Notes:
  - Android uses adaptive icon redraw instead of reusing iOS asset slices.
```

---

## 6. 当前已知基线记录

## 2026-05-08 - Blue AI Theme Refresh

- Source:
  - commit: `696d953`
  - primary platform: `iOS`
- Change type:
  - `Design Token Change`
- Affected source of truth:
  - `Docs/cross-platform/design-tokens.md`
- Impact:
  - `accent.primary`
  - `accent.secondary`
  - `bg.*`
  - `bg.grouped.*`
  - `label.*`
  - `separator.default`
  - `status.mark`
  - `chart.*`
  - `background.vc`
  - `background.list`
  - `action.send`
  - `action.checkSelected`
  - `action.likeSelected`
  - `action.unlikeSelected`
- Synced:
  - [x] iOS
  - [x] Android
  - [ ] Web
  - [ ] Desktop
- Notes:
  - Android 已建立 `apps/android/core/ui/theme` token 映射。
  - Web 与 Desktop 仍待映射。

## 2026-05-08 - Token Naming Fix

- Source:
  - primary platform: `iOS`
- Change type:
  - `Design Token Change`
- Affected source of truth:
  - `Docs/cross-platform/design-tokens.md`
- Impact:
  - `tertiary` naming normalization
- Synced:
  - [x] iOS
  - [x] Android
  - [ ] Web
  - [ ] Desktop
- Notes:
  - 禁止在新代码中继续使用 `tertiery` 拼写。

---

## 7. 给 AI 的执行规则

以后让 AI 协助多端同步时，任务描述优先写成：

- “这是一次 `Design Token Change`，先更新 `design-tokens.md`，再同步 Android theme”
- “这是一次 `Domain Change`，先更新领域模型母版，再同步 iOS/Android”
- “这是一次 `Platform Implementation Change`，只改 Android，不同步其它端”

避免写成：

- “把这个页面顺手同步到其它端”
- “iOS 改完了，帮我都改一下”

前一种表达能让 AI 稳定按规则执行，后一种表达会把平台实现和跨端源事实混在一起。

---

## 一句话结论

四端同步不是“看到一端改了，就去抄另外三端”，而是“先确认这次改动是不是跨端源事实，再按固定顺序更新母版和各端实现”。
