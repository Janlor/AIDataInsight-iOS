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
npm run dev:mock
npm run dev:local
npm run typecheck
npm run test
npm run build
```

## 环境配置

默认不配置环境变量时，Web 端使用跨平台契约里的 Apifox mock host。

环境由 `NEXT_PUBLIC_APP_ENV` 和 `NEXT_PUBLIC_API_BASE_URL` 控制：

| 环境 | 用途 | 默认 base URL |
| --- | --- | --- |
| `mock` | 默认开发联调，使用 Apifox mock | `https://m1.apifoxmock.com/m1/3174267-1700689-default` |
| `local` | 本地离线开发、E2E 稳定测试 | `http://localhost:3000/api/mock` |
| `dev` | 真实 DEV 后端 | 必须显式配置 |
| `test` / `sit` / `uat` | 测试环境 | 必须显式配置 |
| `pre` | 预发环境 | 必须显式配置 |
| `prod` | 生产环境 | 必须显式配置 |

常用启动方式：

```sh
npm run dev:mock   # Apifox mock
npm run dev:local  # local Next.js mock route
```

也可以复制对应示例文件为 `.env.local`：

```sh
cp .env.mock.example .env.local
cp .env.local.example .env.local
cp .env.dev.example .env.local
cp .env.test.example .env.local
cp .env.pre.example .env.local
cp .env.prod.example .env.local
```

`dev/test/sit/uat/pre/prod` 如果没有配置 `NEXT_PUBLIC_API_BASE_URL`，启动或构建时会直接报错，避免误打默认 mock。

## 本地 Mock API

本地 mock API 只作为离线开发和 E2E 的稳定夹具，不替代 Apifox mock。

它覆盖了第一阶段主链路：

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

Playwright E2E 固定使用本地 mock：

```sh
npx playwright install --only-shell chromium
npm run e2e
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
- AI Chat 发送流程和历史详情恢复
- SSE 流式响应、图表组件和本地 mock API
- Apifox mock / local mock / dev / test / pre / prod 环境矩阵

下一步优先补齐部署侧 CI 环境变量配置和 runtime validation。
