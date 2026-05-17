# AIDataInsight Web

这个目录是 AIDataInsight Web 端工程，基于 Next.js App Router、React、TypeScript 和 Tailwind CSS 搭建。

Web 端实现应该从下面这些源事实开始：

- `src/contracts/generated/models.ts`
- `docs/cross-platform/contracts/api/openapi.yaml`
- `docs/cross-platform/contracts/usecases/*.usecases.yaml`
- `docs/cross-platform/contracts/fixtures/**/*`

不要从 iOS UIKit 页面反推 Web 的领域模型或 use case 输出。如果缺少某个模型或行为，先更新 `docs/cross-platform/contracts`，再运行：

```sh
scripts/generate-cross-platform-contracts.sh
```

## 开发命令

```sh
npm install
npm run dev
npm run typecheck
npm run test
npm run build
```

## 当前进度

已完成第一批 Web 基线：

- Next.js / React / TypeScript 工程骨架
- Tailwind CSS 基础主题
- `/login`、`/ai`、`/history`、`/setting`、`/privacy` 路由
- Web shell、导航和登录态守卫
- HTTP client、response envelope 和 `401` / `402` session 规则
- 登录、refresh、logout、getUserInfo 账户 API 封装
- snake_case token 归一化测试
- `402` refresh 后重试测试
- AI Chat template / function / chart / feedback API 封装
- History page / detail / delete API 封装
- AI Chat 和 History contract fixtures mapper 测试

下一步优先接入 AI Chat 发送流程、历史详情恢复和 mock server。
