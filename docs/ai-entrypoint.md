# AIDataInsight AI 协作入口

这份文档给人看：新员工、新 AI 工具、新模型或新对话开始工作时，先从这里进入。目标是让 AI 不必每次全量读取 `docs`，只读取当前任务真正需要的最小上下文，降低 token 消耗，也减少跨端契约漂移。

## 第一步

在仓库根目录运行：

```sh
scripts/check-contract-alignment.sh all
scripts/check-contract-alignment.sh app-apple
scripts/check-contract-alignment.sh app-web
```

脚本会输出：

- 当前契约版本
- 目标端已消费的契约版本
- 待处理迁移
- 目标端最小读取文件集合

## 日常读取顺序

普通维护、迁移、修 bug 时，只读这些：

1. `docs/ai-entrypoint.md`
2. `docs/cross-platform/contracts/contract-manifest.yaml`
3. 目标端的 `contract-alignment.json`
4. 检查脚本输出的待处理 migration 文件
5. migration 中明确要求读取的契约文件
6. 目标端本次会修改的代码

只有在新增复杂功能、创建新端、重构生成器，或 migration 明确要求时，才按需读取 `docs/ai-generation-guide.md` 的相关小节和更大范围的契约文档；不要默认完整读取全文。

## 契约规则

- 契约文件是跨端源事实，不能以某一端实现作为最终事实。
- 如果端侧实现暴露契约缺失，先补契约和 migration，再改端侧代码。
- 不能用客户端补数据来掩盖接口或契约错误。
- 端侧代码和测试未满足 migration 验收标准前，不能把该端标记为 aligned。
- 生成模型必须通过脚本重新生成，不能手改生成产物。

## 文档语言规则

- 给人看的文档优先写中文，方便团队沟通、评审和新成员理解。
- 给 AI、脚本或机器消费的文件可以写英文，减少解析歧义并保持跨工具稳定。
- 如果同一份文档同时服务人和 AI，说明性内容写中文；给 AI 的 prompt 默认写中文并明确要求中文回复；schema、manifest、migration 字段等机器内容可以保持英文。

## 版本位置

当前契约版本在：

```text
docs/cross-platform/contracts/contract-manifest.yaml
```

各端消费到的契约版本在：

```text
app-ios/contract-alignment.json
app-android/contract-alignment.json
app-harmony/contract-alignment.json
app-web/contract-alignment.json
app-apple/contract-alignment.json
```

某端完成一次契约迁移后：

1. 修改端侧代码
2. 新增或更新测试
3. 更新该端的 `contract-alignment.json`
4. 运行 `scripts/check-contract-alignment.sh <app>`
5. 运行该端相关构建或测试命令

## AI 任务模板

不要在聊天里临时手写长提示词。常用提示词统一沉淀在：

```text
docs/ai-task-templates.md
```

新对话里只需要让 AI 使用对应模板即可，例如：

```text
使用 docs/ai-task-templates.md 中的 Contract Migration Template 处理 app-apple。
```

## 多团队协作

- 契约 owner 维护 `docs/cross-platform/contracts`、migrations 和 fixtures。
- 各端团队只消费待处理 migrations，按自己的发布节奏升级。
- 不同端团队不需要互相读取源码。
- 跨端一致性通过契约、fixtures、migrations 和 alignment check 保证。
- 未来拆仓库时，`docs/cross-platform/contracts` 可以迁移为独立契约仓库，各端继续保留自己的 `contract-alignment.json`。
