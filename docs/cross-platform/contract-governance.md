# 契约治理方案

当前项目仍是 monorepo，但契约目录已经按“未来可拆成独立契约仓库”的方式组织。

## 核心文件

- `docs/cross-platform/contracts/contract-manifest.yaml`
  当前契约版本、迁移索引、各端 alignment 文件路径和检查命令。
- `docs/cross-platform/contracts/migrations/*.yaml`
  版本化迁移记录。每条 migration 描述影响端、必要动作、最小读取集合和验收标准。
- `app-*/contract-alignment.json`
  每端已消费的契约版本、最近应用的 migration、当前对齐状态。
- `scripts/check-contract-alignment.sh`
  本地检查脚本，用于发现某端是否落后当前契约版本。
- `docs/ai-task-templates.md`
  给 AI 使用的标准任务模板，避免每次复制粘贴长提示词。
- `docs/cross-platform/change-log.md`
  轻量变更索引，只保留活跃迁移、最近记录和归档入口。
- `docs/cross-platform/changelog-archive/`
  历史归档。默认不读，只有需要追溯背景时按月份读取。

## 文档语言规范

- 给人看的文档优先写中文，包括治理说明、使用说明、流程说明、评审说明和新人指南。
- 给 AI 的 prompt 模板默认写中文，并明确要求中文回复，避免 AI 因英文提示切换语言。
- 给机器看的内容可以写英文，包括 manifest、schema、OpenAPI、migration 字段、脚本输出字段和生成配置。
- 混合文档中，解释性段落写中文；需要被机器稳定解析的片段可以保留英文。

## 变更流程

1. 先更新机器可读契约。
2. 行为变化时新增或更新 fixtures。
3. 新增 migration 文件。
4. 更新 `contract-manifest.yaml`。
5. 只在必要时更新解释性文档。
6. 受影响端按 migration 修改端侧代码。
7. 更新该端的 `contract-alignment.json`。
8. 运行 alignment check 和目标端测试。
9. 如果记录进入 changelog，最新记录写在 `change-log.md` 顶部；旧记录按月份移入 `changelog-archive/`。

## 版本规则

- Patch：文案、元数据、非行为性 fixtures、生成元信息更新。
- Minor：向后兼容的契约新增，或更严格但可渐进落地的端侧实现规则。
- Major：API、模型、use case、布局语义、持久化边界等破坏性变化。

## 多仓库演进

公司大型项目可以演进为：

```text
aidatainsight-contracts
aidatainsight-ios
aidatainsight-android
aidatainsight-web
aidatainsight-harmony
aidatainsight-apple
```

拆仓库后：

- 契约仓库发布 `contractVersion`。
- 每端仓库保留自己的 `contract-alignment.json`。
- 各端团队只需要读取契约仓库和本端仓库。
- 多端不必互相开放源码。
- 端侧升级契约时按 migration 逐条消费。

这样可以同时支持独立权限、独立发布和跨端一致性。
