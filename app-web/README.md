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

## 本地 Mock API

默认不配置环境变量时，Web 端会使用跨平台契约里的 Apifox mock host。

如需完全使用本地 mock API，复制 `.env.local.example` 为 `.env.local`，然后启动：

```sh
npm run dev
```

本地 mock 覆盖了第一阶段主链路：

- `POST /oauth2/login`
- `GET /oauth2/refresh`
- `GET /oauth2/logout`
- `GET /oauth2/getUserInfo`
- `GET /chat/template`
- `GET /chat/function`
- `GET /stream`
- `GET /chart/querySalesGroupByMonth`
- `GET /history/page`
- `GET /history/detail`
- `POST /history/like`
- `GET /history/delete`
- `GET /history/deleteAll`

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
- AI Chat 发送流程和历史详情恢复
- SSE 流式响应、图表组件和本地 mock API

下一步优先接入图表反馈交互、历史删除交互和页面级 E2E。
