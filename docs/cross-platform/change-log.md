# 跨平台变更索引

这份文档只保留当前活跃变更、最近记录和归档索引，按倒序排列。完整历史进入 `docs/cross-platform/changelog-archive/`。

AI 默认不要全文读取归档。日常处理契约迁移时应先运行：

```sh
scripts/check-contract-alignment.sh <app>
```

然后只读取脚本输出的 migration 和最小文件集合。只有在 migration 明确要求追溯背景时，才读取归档文件中的对应记录。

## 阅读规则

- 新记录写在本文件顶部。
- 已版本化的契约变更优先写入 `docs/cross-platform/contracts/migrations/*.yaml`。
- `change-log.md` 只保留 migration 链接、影响范围和最近上下文，不重复长篇规则。
- 旧记录按月份归档，不作为新 AI / 新对话默认上下文。

## Active Contract Migrations

### 0.2.0 - AccountUser Protected Persistence

- Migration: `docs/cross-platform/contracts/migrations/0.2.0-account-user-protected-persistence.yaml`
- Manifest: `docs/cross-platform/contracts/contract-manifest.yaml`
- Status:
  - `app-ios`: aligned
  - `app-apple`: aligned
  - `app-android`: needs-review
  - `app-harmony`: needs-review
  - `app-web`: needs-review

核心规则摘要：

- `/oauth2/login` 只返回 OAuth token。
- `/oauth2/getUserInfo` 返回 `AccountUser`。
- `AccountUser` 必须进入受保护账号存储；Apple 端使用 Keychain，不进 SwiftData。
- Setting 先渲染本地 cached AccountUser，再静默刷新远程数据。
- logout、401、402 refresh 失败必须同时清理 session 和 userInfo。

## Recent Records

### 2026-05-20 - Contract Version Alignment Workflow

新增契约版本与多端对齐机制：

- `docs/cross-platform/contracts/contract-manifest.yaml`
- `docs/cross-platform/contracts/migrations/*.yaml`
- `app-*/contract-alignment.json`
- `scripts/check-contract-alignment.sh`
- `docs/ai-entrypoint.md`
- `docs/ai-task-templates.md`
- `docs/cross-platform/contract-governance.md`

目标：

- 新 AI / 新对话先跑 alignment check。
- 只读取 pending migration 的最小上下文。
- 各端独立记录已消费契约版本。
- 未来可平滑拆分为独立 contracts 仓库和多端仓库。

### 2026-05-20 - AccountUser Protected Persistence Contract

Apple 全平台实现 Setting 时发现只持久化 `AccountSession` 会导致设置页先显示默认账户占位，再等待 `/oauth2/getUserInfo` 刷新真实用户信息。

回看现有 `app-ios`，`AccountRouter.updateUser` 已将 `UserInfoMO` 保存到 Keychain，`SettingRepository` 从 `AccountUserStore.getUser` 读取本地用户资料。

已沉淀为 migration：

- `docs/cross-platform/contracts/migrations/0.2.0-account-user-protected-persistence.yaml`

### 2026-05-16 - HarmonyOS NEXT Stage 10 Closure

完整历史已归档：

- `docs/cross-platform/changelog-archive/2026-05.md`

摘要：

- `app-harmony` 已完成阶段 10 收尾。
- 当前连接 Apifox mock 环境，覆盖 Login、自动登录、AIHome、History、Setting、Privacy、AIChat、图表 fallback 和反馈状态。
- 当前开源版本默认连接 Apifox mock 环境；后续如需接入其它环境，应先更新跨端契约和网络配置。

## Archive Index

- `docs/cross-platform/changelog-archive/2026-05.md`
  - 原 `change-log.md` 完整历史快照。
  - 包含跨平台变更流程说明、HarmonyOS NEXT 各阶段记录、Account/Setting/History/AIChat 契约记录等。

## Historical Governance Summary

这些长期规则已经沉淀到更合适的位置：

- AI 入口与最小读取：`docs/ai-entrypoint.md`
- AI 任务模板：`docs/ai-task-templates.md`
- 契约治理流程：`docs/cross-platform/contract-governance.md`
- 契约生成协议：`docs/ai-generation-guide.md`
- 当前契约版本与迁移索引：`docs/cross-platform/contracts/contract-manifest.yaml`
- 机器可读契约：`docs/cross-platform/contracts/`
