# core/account

账号域封装登录态、用户信息缓存、自动登录判断和受保护账号状态清理。

当前已实现：

- `AccountSessionStore.ets`：定义 session store 协议、空 session、内存实现、Preferences 实现和自动登录判断。
- `AccountUserStore.ets`：定义 AccountUser store 协议、内存实现和同账号边界的 Preferences 实现。
- `AccountAuthService.ets`：封装登录、读取当前 session/user、刷新用户信息、自动登录判断和退出登录。

规则：

- 页面不能直接判断 token 字段来决定导航。
- 自动登录统一走 `shouldAutoLogin(session)`。
- `AccountUser` 只来自 `/oauth2/getUserInfo`，登录响应不作为用户信息来源。
- 退出登录和 session 失效必须同时清理 `AccountSession` 与 `AccountUser`。
