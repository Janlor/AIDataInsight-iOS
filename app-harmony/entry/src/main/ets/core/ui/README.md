# core/ui

后续实现主题 token、统一背景、安全区策略和基础组件。

当前已实现：

- `theme/AppTheme.ets`：颜色、间距、圆角、字号 token。
- `components/AIDataInsightGradientBackground.ets`：统一渐变背景。
- `components/SafeAreaPage.ets`：页面安全区内边距容器。
- `components/PrimaryButton.ets`：统一主按钮。
- `components/ListRow.ets`：设置、历史等列表行基础样式。

规则：

- 页面背景优先复用 `AIDataInsightGradientBackground`。
- 页面内容区域优先通过 `SafeAreaPage` 控制安全区和 readable padding。
- 按钮、列表行先复用 core 组件，再按 feature 做少量扩展。
