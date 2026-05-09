# AIDataInsight AI 生成协议

## 文档目的

这份文档固定 AI 生成 iOS / Android / Web / 鸿蒙 / 其它候选端代码时必须遵守的协议。

它的目标不是让 AI “看着某一端页面照抄”，而是让 AI 只从跨平台契约、目标端模块映射和 golden fixtures 出发，稳定地产生各端实现。

当你让 AI 生成或修改任意端代码时，优先把这份文档作为提示词的一部分。

---

## 一、核心原则

### 1. 契约优先

跨端源事实只来自：

- `docs/cross-platform/contracts/domain/*.schema.json`
- `docs/cross-platform/contracts/api/openapi.yaml`
- `docs/cross-platform/contracts/usecases/*.usecases.yaml`
- `docs/cross-platform/contracts/ui-state/*.yaml`
- `docs/cross-platform/contracts/ui-layout/*.yaml`
- `docs/cross-platform/contracts/routes/route-intents.yaml`
- `docs/cross-platform/contracts/design/tokens.json`
- `docs/cross-platform/contracts/fixtures/**/*`

任何端的页面、Cell、Compose UI、React 组件、Controller、ViewModel 都不能作为跨端源事实。

### 2. iOS 是参考实现，不是复制来源

iOS 当前可以作为参考实现，用来理解：

- 当前业务是否已经跑通
- repository / usecase / presentation 的职责边界
- 某些历史兼容细节

但 AI 不能从这些 iOS 对象反推出其它端模型：

- `AIChat`
- `AIBarChartData`
- `HistorySectionViewData`
- UIKit Cell
- `UIViewController`
- iOS Router 调用

如果契约和 iOS 代码不一致，先停下来说明差异；不能擅自以 iOS 页面为准。

### 3. 生成的是端侧实现，不是新契约

AI 生成目标端代码时，不能随手创造新的领域字段、新的 API 路径、新的 use case 分支。

如果确实缺字段或规则，必须先更新 `docs/cross-platform/contracts/`，再生成目标端代码。

---

## 二、固定读取顺序

每次让 AI 生成某个功能时，必须按下面顺序读取上下文。

1. 读取 `docs/cross-platform/contracts/README.md`
2. 读取 `docs/cross-platform/contracts/domain/` 中相关 schema
3. 读取 `docs/cross-platform/contracts/api/openapi.yaml`
4. 读取 `docs/cross-platform/contracts/usecases/` 中相关 usecase 契约
5. 读取 `docs/cross-platform/contracts/ui-state/` 中相关 state 契约
6. 读取 `docs/cross-platform/contracts/ui-layout/` 中相关 layout 契约
7. 读取 `docs/cross-platform/contracts/routes/route-intents.yaml`
8. 读取 `docs/cross-platform/contracts/fixtures/` 中相关 golden fixtures
9. 读取目标端模块映射文档
10. 读取目标端现有代码结构
11. 再开始设计或改代码

目标端模块映射文档：

- Android：`app-android/docs/android-module-mapping-checklist.md`
- Android / Web 脚手架：`docs/architecture/android-web-scaffold-design.md`
- 总体蓝图：`docs/architecture/cross-platform-blueprint.md`
- 端侧优先级和技术栈：`docs/architecture/platform-adaptation-strategy.md`

---

## 三、固定生成顺序

生成一个 feature 时，按下面顺序产出。

### 1. Contract Models

优先运行：

```sh
scripts/generate-cross-platform-contracts.sh
```

生成产物：

- Android：`app-android/core/model/src/main/java/com/aidatainsight/android/core/model/contract/ContractModels.kt`
- Web：`app-web/src/contracts/generated/models.ts`

AI 不应该手写这些生成模型。

### 2. Repository Interface

按 usecase 契约生成仓储协议。

要求：

- 方法名对齐契约语义
- 输入输出使用 contract/application models
- 不返回 UI model
- 不直接暴露平台控件对象

示例职责：

- `AIChatRepository`
- `HistoryRepository`
- `SessionRepository`
- `SettingsRepository`

### 3. Data / DTO / Mapper

按 `openapi.yaml` 和 fixtures 生成数据层。

要求：

- API path / method / parameter 以 OpenAPI 为准
- 响应外壳保留 `code` 和 `msg`
- `401` / `402` 必须按契约处理
- DTO 可以是端侧实现细节，但 DTO -> domain mapper 必须可测

### 4. UseCase

按 `contracts/usecases/*.usecases.yaml` 生成 use case。

要求：

- UseCase 只返回 application output
- 不返回 UIKit / Compose / React / ArkUI / Desktop UI model
- 不处理具体页面跳转
- 不读取平台控件状态

### 5. UI State Mapper

把 application output 映射成本端 UI state。

要求：

- Android 映射到 Compose 需要的 state / model
- Web 映射到 React state / hook result
- iOS 映射到 UIKit view data
- 鸿蒙映射到 ArkUI 页面状态
- Desktop 映射到本端 native UI model

### 6. UI Implementation

最后才实现 UI。

要求：

- UI 只消费本端 UI state
- UI 不直接解析 DTO
- UI 不直接拼 API 请求参数
- UI 不重新实现 use case 分支
- UI layout 必须读取并遵守 `contracts/ui-layout/*.yaml`
- 沉浸式背景和安全区要分层处理：背景可以延伸到系统栏或浏览器安全区下面，内容必须避开 safe area / home indicator / gesture area / cutout / 软键盘
- 页面高度不足、横屏、小屏和键盘弹出时，内容必须可滚动，不能让关键控件不可达
- 宽屏和横屏不能简单把竖屏 UI 缩窄居中；如果 layout 契约声明了 regular/landscape 分栏，必须实现目标端原生的响应式布局
- 表单类页面应使用 readable content width，而不是在宽屏上贴边铺满
- 图标类 toggle 的点击反馈不能出现与图标形状不匹配的默认方块高亮；反馈应限定在图标形状内，或使用无可见反馈/本端原生触感反馈

#### AI Home / 主入口生成规则

登录成功后的 AI 业务主入口必须读取：

- `docs/cross-platform/contracts/domain/ai-home.schema.json`
- `docs/cross-platform/contracts/usecases/ai-home.usecases.yaml`
- `docs/cross-platform/contracts/ui-state/ai-home-state.yaml`
- `docs/cross-platform/contracts/ui-layout/ai-home-layout.yaml`
- `docs/cross-platform/contracts/fixtures/ui/ai-home-*.json`

生成要求：

- AI Home 是已认证 app shell；未登录时必须走 `routeIntent.openLogin`，不能渲染受保护的 AI 内容。
- 登录成功必须替换主 app surface/root，而不是把 AI Home push 到登录页之上。
- AI Home 默认主内容是 AI Chat，`selectedHistoryId = null` 时加载模板问题。
- History 是辅助面板/侧栏，不是新的根页面；打开或关闭 History 不得销毁 AI Chat 状态。
- 选择历史会话后，关闭 History 面板，并命令 AI Chat 在原位加载该 `historyId`，不能 push 第二个 Chat 页面。
- 开始新会话必须清空 `selectedHistoryId`，命令 AI Chat 清空当前消息并重新加载模板问题。
- 删除当前选中的历史会话或清空全部历史时，AI Chat 必须回到新会话状态；删除非当前会话不能重置聊天。
- 设置入口使用 `routeIntent.openSettings`，由目标端选择 modal、sheet、page 或 navigation destination。
- Chat / History 切换时，背景层、灰色蒙层和 History 面板容器必须覆盖完整 viewport，包括 status bar、home indicator、浏览器安全区和手势区域；内容层再单独避让 safe area。
- 不要把 safe-area padding 加在承载抽屉、蒙层或背景的外层容器上，否则拖拽打开 History 时会露出顶部/底部空白带。
- History 面板的渐变/列表背景必须画到系统栏底下；标题、刷新、设置、列表项和删除按钮必须留在 safe drawing area 内。
- 如果目标端组件自带 drawer/sheet/list inset，必须判断它是否制造了未绘制的顶部或底部空白；如有冲突，应关闭默认 inset，由契约定义的背景层和内容层分别处理。
- Android/Web 不得照抄 iOS `ContainerViewController.addChild`、`UINavigationController`、transform 手势实现；只能复用其表达的内容切换语义。

#### AI Chat Template 解析规则

`/chat/template` 的领域输出固定为 `TemplateQuestionSet`：

```text
TemplateQuestionSet.questions: string[]
```

当前 mock 接口可能把 `data` 返回为内嵌 JSON 字符串，而不是直接返回对象。目标端生成代码时必须：

- 在网络层或 AI Chat remote service 把 `data` 归一化为 `TemplateQuestionSet`。
- 同时兼容 `data` 是对象和 `data` 是 JSON 字符串两种形态。
- Repository / UseCase 只能返回 `TemplateQuestionSet` 或 application output，不能把接口 `String data` 泄漏给上层。
- UI 不得为了显示推荐问题去解析接口 JSON 字符串。

---

## 四、动态函数参数生成协议

AI Chat 的主链路必须固定为：

```text
FunctionName -> FunctionArguments kind -> /chart/{FunctionName.rawValue} -> ChartPayload
```

源事实：

- `docs/cross-platform/contracts/usecases/ai-chat.usecases.yaml`
- `docs/cross-platform/contracts/domain/ai-chat.schema.json`
- `docs/cross-platform/contracts/fixtures/function-response/*.json`

生成要求：

- `FunctionName` 不允许私自重命名
- `FunctionName -> FunctionArguments` 映射必须来自 `dynamicFunctionContract`
- 图表请求路径必须是 `/chart/{functionName}`
- 图表请求参数必须是 `historyId + arguments fields`
- 图表输出必须先变成 `ChartPayload`
- 页面图表模型只能由 `ChartPayload` 映射得到

禁止：

- 把 `arguments` 长期建模成裸字典
- 每端维护一份不同的 `name -> arguments` switch
- 某一端把 `/chart/{name}` 改成多个硬编码 endpoint
- 把后端 chart JSON 直接展示到页面

---

## 五、平台生成规则

### Android

优先生成顺序：

1. `core:model/contract`
2. `core:network`
3. `feature/*/domain`
4. `feature/*/data`
5. `feature/*/application/usecase`
6. `feature/*/presentation`
7. `feature/*/ui`

规则：

- 使用 Kotlin / Coroutines / Flow
- Compose 只在 UI 层出现
- UseCase 不返回 `HistorySectionUiModel` 这类 UI model
- Repository 不依赖 Compose
- 生成模型来自 `ContractModels.kt`

### Web

优先生成顺序：

1. `src/contracts/generated`
2. `src/domain`
3. `src/data`
4. `src/features/*/application`
5. `src/features/*/state`
6. `src/features/*/components`
7. Next.js route / page

规则：

- 使用 TypeScript
- API 类型来自 `models.ts` 和 OpenAPI
- React 组件只消费 UI state
- hooks / actions 不重新定义领域模型
- 缺模型先改契约，不在组件里临时补字段

### iOS

规则：

- iOS 可以继续使用 UIKit
- UseCase 只返回 application output
- UIKit view data 必须在 Presentation 层映射
- 不把 `UIViewController` / `IndexPath` / `NSAttributedString` 放进 Application 层

#### iOS 网络边界规则

iOS 当前网络主链路是：

```text
Domain endpoint / RequestDescriptor -> CommonRequester -> Repository -> UseCase -> ViewModel
```

AI 修改 iOS 网络请求时必须遵守：

- 子模块 API path 必须先落在本模块的 API descriptor 中，例如 `ChatApi`、`HistoryApi`、`ChartApi`，或者新增同级的 `StreamApi`。
- Repository 只能调用 API descriptor 和 `CommonRequester`，不能自己拼完整 URL，不能自己构造底层网络配置。
- 流式接口也必须走同一边界：先在 `ChatApi.stream` 或同级 `StreamApi` 描述 path / method / parameters / headers，再由 `CommonRequester.requestSSE(...)` 发起请求。
- `CommonRequester` 是 iOS 业务层访问网络的 façade；如果它缺少某种请求入口，应优先给 `CommonRequester` 增加稳定入口，而不是让 Repository 绕过它。
- `Networking`、`NetworkServer`、`RequestBuilder`、`URLSession` 等底层设施只能出现在网络基础设施层、API descriptor 层或 `CommonRequester` 内部，不能泄漏到业务 Repository。
- 全局 `Environment` 只放 host、渠道、OAuth、上传地址等真正跨模块运行时配置；子模块 endpoint path 属于对应领域契约，例如 AI Chat 的 `/stream` 属于 `AIChatEndpoint`。

禁止：

- 在 `DefaultAIChatRepository`、`DefaultHistoryRepository`、`DefaultLoginRepository` 等业务 Repository 中 `import Networking` 来读取 `NetworkServer` 或底层配置。
- 在 Repository 中写死 `https://.../stream` 这类完整 URL。
- 因为某个请求是 SSE / 文件 / 特殊接口，就跳过 `ChatApi` / `StreamApi` / `CommonRequester` 这条边界。
- 把子模块 URL path 放到全局环境配置中，例如把 AI Chat 的 `/stream` 写成 `Environment.server.aiChatStreamURL` 或 Android 的全局 `NetworkConfig.aiChatStreamPath`。

正确示例：

```swift
enum ChatApi: RequestDescriptor {
    case stream(String)

    var path: String {
        switch self {
        case .stream:
            return AIChatEndpoint.streamPath
        }
    }
}

struct DefaultAIChatRepository: AIChatRepository {
    func streamMessage(_ text: String) -> AsyncThrowingStream<String, Error> {
        CommonRequester.requestSSE(ChatApi.stream(text))
    }
}
```

错误示例：

```swift
struct DefaultAIChatRepository: AIChatRepository {
    func streamMessage(_ text: String) -> AsyncThrowingStream<String, Error> {
        let url = NetworkServer.aiChatStreamURL
        var request = URLRequest(url: url)
        return CommonRequester.requestSSE(request)
    }
}
```

### 鸿蒙 HarmonyOS / OpenHarmony

规则：

- 暂不作为前三端同阶段目标
- 若启动，优先使用 ArkTS + ArkUI + DevEco Studio
- 先生成 contract models 和 mapper，再生成 ArkUI 页面
- 没有真机时，必须明确说明设备能力、性能和发布链路未验证
- 不从 iOS UIKit、Android Compose 或 Web React 页面反推鸿蒙模型

### macOS / Windows 等候选桌面端

规则：

- macOS 短期依赖 iPadOS 兼容模式即可
- SwiftUI 化后再评估 macOS 原生 target
- Windows 暂不规划，未来优先 Web / PWA / Tauri / Electron
- 只有确认真实桌面端业务需求后，才进入单独适配

---

## 六、固定验证协议

每次生成或修改跨端相关代码后，至少运行：

```sh
scripts/validate-cross-platform-contracts.sh
scripts/generate-cross-platform-contracts.sh
```

如果修改 Android contract model 或依赖它的代码，运行：

```sh
cd app-android
./gradlew :core:model:compileDebugKotlin
```

如果修改 iOS `module-ai`，在有完整 Xcode / iOS SDK 的环境运行对应测试；如果当前环境只有 CommandLineTools，要在回复里说明无法完成 UIKit 依赖测试。

如果修改 Web，运行项目中的 TypeScript / lint / test 命令；如果 Web 工程还没有建立，也要说明当前只能校验生成文件和契约。

---

## 七、AI 输出要求

AI 最终回复必须说明：

- 读取了哪些契约文件
- 生成或修改了哪些端
- 哪些文件是生成产物
- 哪些文件是手写实现
- 跑了哪些验证
- 哪些验证因为环境限制没有跑

如果遇到契约缺失，AI 必须先说明缺口，并建议更新哪个 contract 文件，不能绕过契约直接在端侧补私有字段。

---

## 八、提示词模板

可以直接复制下面这段给 AI：

```text
请严格按 `docs/ai-generation-guide.md` 生成代码。

目标端：
- Android / Web / iOS / 鸿蒙 / 其它候选端

目标功能：
- 在这里描述功能

要求：
1. 先读取 `docs/cross-platform/contracts/README.md`。
2. 再读取相关 domain schema、OpenAPI、usecase、ui-state、fixtures。
3. 不要从 iOS UIKit 页面或 ViewData 反推领域模型。
4. 如果契约缺字段或缺规则，先指出并更新 contract。
5. 生成端侧代码时，按 Contract Models -> Repository -> Data -> UseCase -> UI State Mapper -> UI 的顺序。
6. 修改 iOS 网络请求时，必须保持 `API descriptor -> CommonRequester -> Repository` 边界；Repository 不能引入 `Networking`、不能拼完整 URL、不能绕过 `CommonRequester`。
7. 子模块 endpoint path 必须沉到对应领域契约，不能放进全局环境配置；全局环境只放 host 等跨模块运行时配置。
8. 修改后运行 contract validation 和目标端可用的测试/编译命令。
9. 最终说明生成产物、手写实现、验证结果和未验证风险。
```
