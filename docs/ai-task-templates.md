# AI 任务模板

这份文档保存可以直接复用的 AI 提示词。默认使用中文提示词，避免 AI 因英文提示而切换成英文回复；命令、路径、schema 字段、manifest 字段等机器内容保留英文。

文档语言规则：

- 给人看的说明写中文。
- 给 AI 的提示词默认写中文，并明确要求“回复使用中文”。
- 给机器消费的 schema、manifest、migration 字段可以写英文。
- 不要把这条规则放在聊天里临时提醒，应优先沉淀到文档。

## Contract Migration Template

用途：让新 AI / 新对话按契约版本检查某个端，并只读取最小必要上下文。

使用方式：

```text
使用 docs/ai-task-templates.md 中的 Contract Migration Template 处理 <app>。
```

如果 AI 无法自动代入 `<app>`，把下面模板中的 `<app>` 替换为目标端，例如 `app-apple`、`app-web`、`app-android`。

```text
请先阅读 docs/ai-entrypoint.md，然后运行：
scripts/check-contract-alignment.sh <app>

只读取脚本输出的最小文件集合。为 <app> 应用待处理 migration，更新必要测试，
更新 <app>/contract-alignment.json，并同步更新 docs/cross-platform/change-log.md 中对应 active migration 的端侧状态。
如果这是该 migration 的最后一个待对齐平台，还要把这条契约修改从 Active Contract Migrations 移动到 Recent Records。
除非 migration 明确要求，否则不要读取整个 docs 目录。
最终回复请使用中文。
```

## Contract Change Template

用途：当发现契约缺失或 API/领域事实变化时，先更新契约，再更新端侧。

```text
请使用 docs/ai-entrypoint.md 和 docs/cross-platform/contract-governance.md。

我需要修改跨平台契约。请先识别必须修改的机器可读契约文件；如果行为发生变化，
新增或更新 fixtures；在 docs/cross-platform/contracts/migrations 下创建 migration；
更新 docs/cross-platform/contracts/contract-manifest.yaml；然后列出受影响端和必要端侧动作。
在契约 migration 写完前，不要修改端侧代码。
最终回复请使用中文。
```

## New Platform Feature Template

用途：新增完整 feature、创建新平台实现、或修改生成器时使用。即使使用该模板，也不要默认完整读取 `docs/ai-generation-guide.md`，先按入口和 alignment 判断需要读取哪些小节。

```text
请先阅读 docs/ai-entrypoint.md，然后运行：
scripts/check-contract-alignment.sh <app>

请先只读取脚本输出的最小文件集合。

如果脚本输出、migration 或任务本身表明这是“新增平台项目 / 复杂新 feature / 修改生成器”，
再按需读取 docs/ai-generation-guide.md 中与当前任务相关的小节，不要默认完整读取全文。

请按契约优先的方式为 <app> 实现指定功能，优先使用生成的 contract models，
补充聚焦测试；如果消费了契约 migration，更新 <app>/contract-alignment.json，
并同步更新 docs/cross-platform/change-log.md 中对应 active migration 的端侧状态，
如果这是该 migration 的最后一个待对齐平台，还要把这条契约修改从 Active Contract Migrations 移动到 Recent Records，
并总结验证结果。
最终回复请使用中文。
```
