# AIDataInsight Design Tokens

## 文档目的

这份文档是 AIDataInsight 四端共享的第一份设计母版。

它不描述某个端怎么写界面代码，只描述这些跨端应该保持一致的设计事实：

- 品牌主色与辅助色
- 明暗模式色板
- 背景层级
- 文字层级
- 分割线与状态色
- 图表色板
- 图标与背景资源的语义

当前基线来自 iOS 提交：

- `696d953` `改为更具AI产品科技感的蓝色主题风格`

---

## 1. 品牌方向

### 1.1 主题关键词

- AI 产品感
- 科技感蓝色
- 明亮、理性、可信
- 深色模式下保持高对比与轻微发光感

### 1.2 品牌表达要求

- 主品牌色以高饱和蓝色为核心
- 次级强调色不引入完全不同的品牌方向
- 图表允许扩展到青、薄荷绿、紫、橙、珊瑚色，但仍以蓝色为第一识别色
- 各端可以使用不同控件体系，但视觉重心必须保持一致

---

## 2. Core Color Tokens

### 2.1 Accent

| Token | Light | Dark | Elevated |
| --- | --- | --- | --- |
| `accent.primary` | `#2F7BFF` | `#4C8DFF` | `#5A97FF` |
| `accent.secondary` | `#1A2F7BFF` | `#264C8DFF` | - |

说明：

- `accent.primary` 是品牌主色
- `accent.secondary` 是带透明度的辅助强调层，用于弱化按钮、选中底、轻提示背景

### 2.2 Background

| Token | Light | Dark | Elevated |
| --- | --- | --- | --- |
| `bg.primary` | `#FFFFFF` | `#0B1020` | `#131A2A` |
| `bg.secondary` | `#F4F7FB` | `#151D30` | `#1B2438` |
| `bg.tertiary` | `#FFFFFF` | `#202B42` | `#2A3652` |

### 2.3 Grouped Background

| Token | Light | Dark | Elevated |
| --- | --- | --- | --- |
| `bg.grouped.primary` | `#F4F7FB` | `#0B1020` | `#131A2A` |
| `bg.grouped.secondary` | `#FFFFFF` | `#151D30` | `#1B2438` |
| `bg.grouped.tertiary` | `#EEF3FA` | `#202B42` | `#2A3652` |

### 2.4 Label

| Token | Light | Dark |
| --- | --- | --- |
| `label.primary` | `#111827` | `#F9FAFB` |
| `label.secondary` | `#5B6475` | `#B8C2D9` |
| `label.tertiary` | `#8A94A6` | `#8F9BB3` |
| `label.quaternary` | `#B2BAC8` | `#657089` |
| `label.quinary` | `#D1D5DB` | `#4B5568` |

### 2.5 Border / Separator / Status

| Token | Light | Dark |
| --- | --- | --- |
| `separator.default` | `#E5EAF3` | `#2B364C` |
| `status.mark` | `#FF5A6B` | `#FF6B7A` |

说明：

- `status.mark` 当前用于危险、提醒、删除类高风险动作

---

## 3. Chart Palette Tokens

图表允许使用扩展色，但必须遵守“蓝色优先”的顺序。

### 3.1 Palette Order

1. `chart.blue`
2. `chart.cyan`
3. `chart.mint`
4. `chart.green`
5. `chart.purple`
6. `chart.orange`
7. `chart.coral`

### 3.2 Palette Values

| Token | 100% | 80% | 60% |
| --- | --- | --- | --- |
| `chart.blue` | `#2F7BFF` | `#CC2F7BFF` | `#992F7BFF` |
| `chart.cyan` | `#18B8FF` | `#CC18B8FF` | `#9918B8FF` |
| `chart.mint` | `#33E0C4` | `#CC33E0C4` | `#9933E0C4` |
| `chart.green` | `#3DDC97` | `#CC3DDC97` | `#993DDC97` |
| `chart.purple` | `#8B7CFF` | `#CC8B7CFF` | `#998B7CFF` |
| `chart.orange` | `#FFB547` | `#CCFFB547` | `#99FFB547` |
| `chart.coral` | `#FF6B6B` | `#CCFF6B6B` | `#99FF6B6B` |

规则：

- 首个主序列优先使用 `chart.blue`
- 同系列的弱化层可以使用同色不同透明度
- 不允许各端自行重排色板顺序

---

## 4. Asset Semantics

这部分定义“资源表达什么”，而不是“资源文件怎么存”。

### 4.1 Brand App Icon

语义要求：

- 使用蓝色科技感品牌方向
- 与登录页品牌图标保持同一识别图形
- 小尺寸下仍然可辨识

平台落地：

- iOS 使用 AppIcon 资源集
- Android 使用 adaptive icon
- Web 使用 favicon / app icon 变体
- Desktop 使用各平台图标规范

### 4.2 Login Brand Icon

语义要求：

- 与主 App Icon 同源
- 可以是更适合首屏展示的长宽比版本
- 不允许不同端出现不同品牌图形

### 4.3 Background Assets

当前存在两类语义背景：

- `background.vc`
  - 用于 AI 聊天主视图背景
  - 目标感受是沉浸式、轻科技感、非纯平铺白底
- `background.list`
  - 用于历史列表或分组列表背景
  - 目标感受是较轻的内容容器氛围

规则：

- 各端不必须复用同一张位图
- 但必须保持相同的视觉意图
- 如果平台不适合使用大图背景，可以降级为渐变或带噪点的主题背景

### 4.4 Action Icons

当前已经出现的语义图标：

- `action.send`
- `action.checkSelected`
- `action.likeSelected`
- `action.unlikeSelected`

规则：

- 各端应同步“语义”和“状态”
- 不要求同步位图文件本身
- Android 和 Web 优先使用对应平台可维护的矢量资源

---

## 5. Token Usage Mapping

### 5.1 全局级

- `accent.primary`
  - App 主品牌色
  - 强调按钮
  - 关键选中态
  - 品牌图标主色

- `label.primary`
  - 一级正文
  - 关键标题

- `separator.default`
  - 分割线
  - 弱边框

### 5.2 AI Chat

- `background.vc`
  - AI 聊天页主背景
- `accent.primary`
  - 发送、强调、主交互状态
- `chart.*`
  - 图表系列色

### 5.3 History / List

- `background.list`
  - 历史列表页背景
- `bg.grouped.*`
  - 分组式列表容器背景

### 5.4 Risk / Delete

- `status.mark`
  - 删除
  - 危险确认
  - 高风险提醒

---

## 6. Cross-Platform Sync Rules

### 6.1 必须同步的内容

- token 名称
- token 数值
- 图表色板顺序
- 资源语义
- 明暗模式规则

### 6.2 不直接同步代码的内容

- UIKit / Compose / React 的具体实现
- 动画 API
- 约束与布局代码
- 控件层级结构

### 6.3 修改流程

以后任何一端改主题，先判断是不是 token 变更。

如果是 token 变更，顺序必须是：

1. 先更新这份 `design-tokens.md`
2. 再更新该端实现
3. 再补其它端映射
4. 在变更记录里注明受影响 token

---

## 7. Android / Web / Desktop 落地建议

### Android

- 在 `core/ui/theme` 中建立同名 token
- 优先转成 Compose `ColorScheme` 与自定义扩展 token
- App icon 采用 adaptive icon 重绘

### Web

- 在 `src/styles` 或 `src/theme` 中转成 CSS variables / TS theme object
- 背景图可按 Web 性能和响应式策略做降级

### Desktop

- 保持 token 名称一致
- 按各桌面框架映射到本地主题系统

---

## 8. 当前来源

这份初稿主要从以下 iOS 文件提炼：

- `AIDataInsight/Assets.xcassets/AccentColor.colorset/Contents.json`
- `Packages/library-basics/Sources/BaseUI/ThemeKit/UIColor/theme_colors.json`
- `Packages/module-ai/Sources/ModuleAI/Presentation/Shared/Support/UIColor+AI.swift`
- `Packages/module-ai/Sources/ModuleAI/Presentation/Shared/Charts/AIBarChartData.swift`
- `696d953` 中的品牌图标、背景图、状态图标资源变更

---

## 一句话结论

`696d953` 不应被理解成“一次 iOS UI 微调”，而应被视为 AIDataInsight 四端共享的第一版蓝色科技感主题基线。
