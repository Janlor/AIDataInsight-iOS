# core/account

后续实现 session store、自动登录判断、登录态清理。

当前已实现：

- `AccountSessionStore.ets`：定义 session store 协议、空 session、内存实现和自动登录判断。
- `AccountAuthService.ets`：封装登录、读取当前 session、自动登录判断和退出登录。

规则：

- 页面不能直接判断 token 字段来决定导航。
- 自动登录统一走 `shouldAutoLogin(session)`。
- 后续接持久化时新增 store 实现，不改 feature 登录流程。
