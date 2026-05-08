# AIDataInsight Android 模块映射清单

## 文档目的

这份文档是给你后续实际搭 `apps/android` 用的逐项映射清单。

它不讨论理念，只做一件事：

把当前 iOS 里已经整理好的关键对象，逐项映射到 Android 应该落在哪。

你后面可以把这份文档当成迁移 checklist，一项一项完成。

## 使用方式

每当你准备迁移一个功能时，按下面顺序检查：

1. 先找到 iOS 对应对象
2. 再确认 Android 的推荐落点
3. 决定是“直接镜像”还是“Android 特化”
4. 完成后勾掉这一项

## 状态说明

- `必须镜像`
  - 三端最好保持相同职责和命名
- `结构镜像`
  - 职责相同，但实现方式允许不同
- `Android特化`
  - 只保留意图，不复制 iOS 实现

---

## 一、基础设施层

### 1. `NetworkDependencies`

iOS 对象：

- `Packages/library-basics/Sources/Networking/Session/NetworkDependencies.swift`

Android 落点：

- `apps/android/core/network/NetworkDependencies.kt`
- 或拆成：
  - `apps/android/core/network/auth/NetworkCredentialProvider.kt`
  - `apps/android/core/network/auth/TokenRefreshService.kt`
  - `apps/android/core/network/auth/TokenRefreshCoordinator.kt`
  - `apps/android/core/network/auth/SessionInvalidationHandler.kt`

迁移级别：

- `必须镜像`

迁移要求：

- 保留三组能力接口
- Android 不要把 token、refresh、logout 直接写死在 http client 里

检查项：

- [ ] `NetworkCredentialProvider`
- [ ] `TokenRefreshService`
- [ ] `TokenRefreshCoordinator`
- [ ] `SessionInvalidationHandler`
- [ ] `NetworkDependencies` 或等价装配方式

### 2. `AccountSessionStore`

iOS 对象：

- `Packages/library-basics/Sources/AccountProtocol/AccountProtocol.swift`

Android 落点：

- `apps/android/core/account/session/AccountSessionStore.kt`

迁移级别：

- `必须镜像`

迁移要求：

- 保留这些语义：
  - `isLogin`
  - `accessToken`
  - `refreshToken`
  - `orgId`
  - `username`
  - `update(account:)`
  - `remove()`

检查项：

- [ ] session store 接口
- [ ] 本地存储实现
- [ ] 内存缓存或 state 持有

### 3. `AccountUserStore`

iOS 对象：

- `AccountUserStore`
- `UserInfo`
- `MenuProtocol`
- `UserOrgProtocal`

Android 落点：

- `apps/android/core/account/user/AccountUserStore.kt`
- `apps/android/core/model/account/*`

迁移级别：

- `必须镜像`

迁移要求：

- 用户信息、菜单、组织信息分开存
- 不和 session store 混成一个 God object

检查项：

- [ ] `updateUser`
- [ ] `updateMenus`
- [ ] `updateUserOrgList`
- [ ] `getUser`
- [ ] `getMenus`
- [ ] `getUserOrg`

### 4. `AccountRemoteService`

iOS 对象：

- `AccountRemoteService`
- `Packages/library-basics/Sources/Account/Api/AccountApi.swift`
- `Packages/library-basics/Sources/Account/Services/DefaultAccountRemoteService.swift`

Android 落点：

- `apps/android/core/account/user/AccountRemoteService.kt`
- `apps/android/core/account/user/DefaultAccountRemoteService.kt`

迁移级别：

- `结构镜像`

迁移要求：

- 不要把远程请求留在 session store 实现里
- Android 要做成独立 remote service

检查项：

- [ ] 获取用户信息
- [ ] 获取菜单
- [ ] DTO -> domain 映射

### 5. `AccountRouteService`

iOS 对象：

- `AccountRouteService`
- `toUpdatePassword(from:)`

Android 落点：

- `apps/android/core/account/navigation/AccountRouteService.kt`
- 或 feature 内部 route action

迁移级别：

- `Android特化`

迁移要求：

- 不复制 `UIViewController` 跳转思路
- 只保留“去修改密码页面”这个业务意图

检查项：

- [ ] route action 定义
- [ ] navigation compose 对应实现

---

## 二、公共业务层

### 6. `LoginRepository`

iOS 对象：

- `LoginRepository`
- `DefaultLoginRepository`
- `Packages/library-common/Sources/Login/Repositories/APIs/OAuthApi.swift`
- `Packages/library-common/Sources/Login/Domain/Models/OAuthModel.swift`

Android 落点：

- `apps/android/feature/login/domain/LoginRepository.kt`
- `apps/android/feature/login/data/DefaultLoginRepository.kt`

迁移级别：

- `必须镜像`

迁移要求：

- repository 负责加密、请求、返回 session model
- ViewModel 不直接请求接口

检查项：

- [ ] repository 接口
- [ ] dto
- [ ] repository 实现
- [ ] 登录成功更新 `AccountSessionStore`

### 7. `LoginViewModel`

iOS 对象：

- `LoginViewModel`

Android 落点：

- `apps/android/feature/login/presentation/LoginViewModel.kt`

迁移级别：

- `必须镜像`

迁移要求：

- 只负责编排登录流程和 UI state
- 不要在 Compose Screen 里直接调 repository

检查项：

- [ ] loading state
- [ ] error state
- [ ] login success event

### 8. `SettingSnapshot`

iOS 对象：

- `Packages/library-common/Sources/Setting/Domain/Models/SettingSnapshot.swift`
- `Packages/library-common/Sources/Setting/Domain/Models/SettingAccountInfo.swift`
- `Packages/library-common/Sources/Setting/Domain/Models/SettingCapability.swift`

Android 落点：

- `apps/android/core/model/setting/SettingSnapshot.kt`

迁移级别：

- `必须镜像`

迁移要求：

- 这是三端最值得保持一致的对象之一
- 先有 snapshot，再有 Android 的 UI model

检查项：

- [ ] 账户信息字段
- [ ] capability 字段
- [ ] appVersion 字段

### 9. `SettingRepository`

iOS 对象：

- `SettingRepository`
- `DefaultSettingRepository`

Android 落点：

- `apps/android/feature/setting/domain/SettingRepository.kt`
- `apps/android/feature/setting/data/DefaultSettingRepository.kt`

迁移级别：

- `必须镜像`

迁移要求：

- repository 聚合：
  - `AccountUserStore`
  - `AccountRouteService`
  - `Login` logout service
  - privacy service

检查项：

- [ ] `loadSnapshot`
- [ ] `logout`
- [ ] capability 组装

### 10. `SettingViewModel`

iOS 对象：

- `SettingViewModel`
- `SettingViewData`

Android 落点：

- `apps/android/feature/setting/presentation/SettingViewModel.kt`
- `apps/android/feature/setting/presentation/SettingUiState.kt`

迁移级别：

- `结构镜像`

迁移要求：

- iOS 的 `ViewData` 概念可以映射成 Android 的 `UiState`
- 不要把 Compose 的 icon / color 直接塞进 domain

检查项：

- [ ] snapshot -> ui state 转换
- [ ] logout error event
- [ ] menu item action

### 11. `PrivacyRepository`

iOS 对象：

- `PrivacyRepository`
- `DefaultPrivacyRepository`
- `PolicyManager`

Android 落点：

- `apps/android/feature/privacy/domain/PrivacyRepository.kt`
- `apps/android/feature/privacy/data/DefaultPrivacyRepository.kt`

迁移级别：

- `必须镜像`

迁移要求：

- 同意状态检查
- 最新协议版本保存
- 隐私链接提供

检查项：

- [ ] `isAgreedAllPolicyAgreement`
- [ ] `saveLatestAgreement`
- [ ] `privacyPolicyUrl`

### 12. `PrivacyPolicyViewModel`

iOS 对象：

- `PrivacyPolicyViewModel`
- `PrivacyPolicyAlertContent`

Android 落点：

- `apps/android/feature/privacy/presentation/PrivacyPolicyViewModel.kt`
- `apps/android/feature/privacy/presentation/PrivacyDialogState.kt`

迁移级别：

- `必须镜像`

迁移要求：

- 只弹一次的状态
- alert content
- agree action

检查项：

- [ ] `shouldShowPolicyAgreement`
- [ ] `makeAlertContent`
- [ ] `agreeToLatestPolicy`

---

## 三、AI 业务层

### 13. `HistoryRepository`

iOS 对象：

- `HistoryRepository`
- `DefaultHistoryRepository`

Android 落点：

- `apps/android/feature/history/domain/HistoryRepository.kt`
- `apps/android/feature/history/data/DefaultHistoryRepository.kt`

迁移级别：

- `必须镜像`

检查项：

- [ ] 历史分页加载
- [ ] 删除单条
- [ ] 删除全部

### 14. `LoadHistoryPageUseCase`

iOS 对象：

- `Packages/module-ai/Sources/ModuleAI/Application/UseCases/History/LoadHistoryPageUseCase.swift`
- `Packages/module-ai/Sources/ModuleAI/Application/UseCases/History/DeleteHistoryUseCase.swift`
- `Packages/module-ai/Sources/ModuleAI/Application/UseCases/History/DeleteAllHistoryUseCase.swift`

Android 落点：

- `apps/android/feature/history/application/usecase/LoadHistoryPageUseCase.kt`
- `apps/android/feature/history/application/usecase/DeleteHistoryUseCase.kt`
- `apps/android/feature/history/application/usecase/DeleteAllHistoryUseCase.kt`

迁移级别：

- `必须镜像`

迁移要求：

- Android 也保留 application/usecase 这一层
- ViewModel 只编排，不直接堆叠分页和删除规则

检查项：

- [ ] page load use case
- [ ] delete one use case
- [ ] delete all use case

### 15. `HistoryListViewDataBuilder`

iOS 对象：

- `Packages/module-ai/Sources/ModuleAI/Presentation/History/ViewData/HistoryListViewData.swift`

Android 落点：

- `apps/android/feature/history/presentation/HistoryListBuilder.kt`
- `apps/android/feature/history/presentation/HistorySectionUiModel.kt`

迁移级别：

- `必须镜像`

迁移要求：

- 记录按 today / thisMonth / other 分组
- UI model 独立于 domain model

检查项：

- [ ] `groupRecords`
- [ ] `mergeGroups`
- [ ] `makeSections`

### 16. `HistoryViewModel`

iOS 对象：

- `HistoryViewModel`

Android 落点：

- `apps/android/feature/history/presentation/HistoryViewModel.kt`

迁移级别：

- `必须镜像`

检查项：

- [ ] refresh
- [ ] loadMore
- [ ] deleteOne
- [ ] deleteAll

### 17. `AIChatRepository`

iOS 对象：

- `AIChatRepository`
- `DefaultAIChatRepository`

Android 落点：

- `apps/android/feature/ai-chat/domain/AIChatRepository.kt`
- `apps/android/feature/ai-chat/data/DefaultAIChatRepository.kt`

迁移级别：

- `必须镜像`

检查项：

- [ ] load template
- [ ] load history detail
- [ ] send function message
- [ ] send like feedback
- [ ] stream message

### 18. `Load AIChat UseCases`

iOS 对象：

- `Packages/module-ai/Sources/ModuleAI/Application/UseCases/AIChat/LoadTemplateUseCase.swift`
- `Packages/module-ai/Sources/ModuleAI/Application/UseCases/AIChat/LoadHistoryDetailUseCase.swift`
- `Packages/module-ai/Sources/ModuleAI/Application/UseCases/AIChat/LoadChartDataUseCase.swift`
- `Packages/module-ai/Sources/ModuleAI/Application/UseCases/AIChat/SendFunctionMessageUseCase.swift`
- `Packages/module-ai/Sources/ModuleAI/Application/UseCases/AIChat/SendLikeFeedbackUseCase.swift`
- `Packages/module-ai/Sources/ModuleAI/Application/UseCases/AIChat/StreamAIResponseUseCase.swift`

Android 落点：

- `apps/android/feature/ai-chat/application/usecase/*`

迁移级别：

- `必须镜像`

迁移要求：

- Android 也保留 application/usecase 层
- 把模板、历史详情、图表数据、消息发送、流式响应拆开

检查项：

- [ ] load template use case
- [ ] load history detail use case
- [ ] load chart data use case
- [ ] send function message use case
- [ ] send like feedback use case
- [ ] stream AI response use case

### 19. `AIChatIntentResolver`

iOS 对象：

- `AIChatIntentResolver`

Android 落点：

- `apps/android/feature/ai-chat/presentation/AIChatIntentResolver.kt`

迁移级别：

- `必须镜像`

迁移要求：

- 这块规则三端要一致
- 不要把意图识别混回 ViewModel

检查项：

- [ ] time intent
- [ ] index intent
- [ ] default nil branch

### 20. `AIChatChartBuilder`

iOS 对象：

- `AIChatChartBuilder`

Android 落点：

- `apps/android/feature/ai-chat/presentation/AIChatChartBuilder.kt`

迁移级别：

- `结构镜像`

迁移要求：

- 共用图表数据转换规则
- 不共用图表渲染对象

检查项：

- [ ] chart ui model 构建
- [ ] 单位字符串映射

### 21. `AIChatHistoryMapper`

iOS 对象：

- `AIChatHistoryMapper`

Android 落点：

- `apps/android/feature/ai-chat/presentation/AIChatHistoryMapper.kt`

迁移级别：

- `必须镜像`

检查项：

- [ ] detail -> chat item 映射
- [ ] 历史详情顺序处理
- [ ] 图表类型详情映射

### 22. `FunctionResponseDTO`

iOS 对象：

- `FunctionResponseDTO`
- `FunctionModel`
- `FunctionArguments`
- `FunctionName`

Android 落点：

- `apps/android/feature/ai-chat/data/dto/FunctionResponseDto.kt`
- `apps/android/feature/ai-chat/domain/model/FunctionModel.kt`

迁移级别：

- `必须镜像`

迁移要求：

- DTO 动态解码
- DTO -> domain 映射
- domain 不持有请求库细节

检查项：

- [ ] DTO
- [ ] 动态 arguments 解析
- [ ] toDomain mapping

---

## 四、平台适配层

### 23. iOS `Router`

iOS 对象：

- `Router`
- `RouterServiceStore`

Android 落点：

- `apps/android/app/navigation/AppNavHost.kt`
- 各 feature route

迁移级别：

- `Android特化`

迁移要求：

- 不复制 service locator 路由方式
- 只保留“导航意图”

检查项：

- [ ] 登录路由
- [ ] 设置路由
- [ ] 隐私路由
- [ ] 历史路由
- [ ] AI 聊天路由

### 24. iOS `BaseUI`

iOS 对象：

- `BaseUI`

Android 落点：

- `apps/android/core/ui/`

迁移级别：

- `Android特化`

迁移要求：

- 只镜像主题、间距、常用组件思想
- 不复制 UIKit 组件命名细节

检查项：

- [ ] theme
- [ ] common button
- [ ] loading
- [ ] dialog

---

## 五、迁移顺序清单

建议按这个顺序逐项勾选，不要跳太快：

### 第一阶段

- [ ] `NetworkDependencies`
- [ ] `AccountSessionStore`
- [ ] `LoginRepository`
- [ ] `LoginViewModel`
- [ ] 登录页

### 第二阶段

- [ ] `AccountUserStore`
- [ ] `AccountRouteService`
- [ ] `SettingSnapshot`
- [ ] `SettingRepository`
- [ ] `SettingViewModel`
- [ ] 设置页

### 第三阶段

- [ ] `PrivacyRepository`
- [ ] `PrivacyPolicyViewModel`
- [ ] 隐私弹窗/页面

### 第四阶段

- [ ] `HistoryRepository`
- [ ] `LoadHistoryPageUseCase`
- [ ] `HistoryListBuilder`
- [ ] `HistoryViewModel`
- [ ] 历史页

### 第五阶段

- [ ] `FunctionResponseDto`
- [ ] `AIChat application usecases`
- [ ] `AIChatIntentResolver`
- [ ] `AIChatHistoryMapper`
- [ ] `AIChatRepository`
- [ ] `AIChatViewModel`
- [ ] AI 聊天页

## 六、你在 Android 端最该坚持的规则

### 1. 不要跳过 repository

即使 AI 很容易直接把接口写进 ViewModel，也不要这么做。

### 2. 不要把 Compose UI model 塞回 domain

domain 保持纯净，ui state 单独放。

### 3. 不要重新造一套命名

尽量保留 iOS 这边已经稳定下来的名字。

### 4. 不要先追求页面完成度

先把：

- session
- repository
- snapshot
- builder
- viewmodel

这些结构搭稳。

## 一句话结论

这份文档的作用不是告诉你“Android 应该怎么写得更原生”，而是帮助你把当前 iOS 已经整理出来的结构，准确地逐项映射到 `apps/android`。
