# AIDataInsight Android

AIDataInsight Android 是多端契约的 Android 实现端，目前仍在演进中。它不是从 iOS 页面反推出来的复刻工程，而是按 `docs/cross-platform/contracts` 里的领域模型、UseCase、UI State、UI Layout 和 fixtures 逐步落地。

## 当前状态

- Gradle 多模块工程已建立。
- 登录、设置、隐私、历史、AI Chat、AI Home 主入口已有 Compose 实现。
- `core:network`、`core:account` 已接入 Apifox mock 环境。
- AI Chat / History 主链路正在按契约继续补齐和打磨。
- Android 是第二优先级实现端，细节会随契约和 iOS 参考实现持续调整。

## 模块结构

```text
app-android
├── app                 # Android app 壳、导航、AIHome 组合入口
├── core
│   ├── common          # 通用基础代码
│   ├── model           # 由契约生成的跨端模型
│   ├── network         # Ktor Client、remote service、API 响应处理
│   ├── account         # 登录态、账号会话、账号 remote service
│   ├── ui              # 主题、通用背景、共享 UI token
│   └── testing         # 测试辅助
└── feature
    ├── login           # 登录页
    ├── setting         # 设置页
    ├── privacy         # 隐私协议页
    ├── history         # 历史会话
    └── ai-chat         # AI Chat data/domain/usecase/presentation
```

## 技术栈

- Kotlin
- Jetpack Compose
- Navigation Compose
- Coroutines / Flow
- Kotlinx Serialization
- Ktor Client + OkHttp
- Gradle Android Plugin 8.5.2

## 运行

用 Android Studio 打开：

```text
app-android
```

或在终端运行：

```bash
cd app-android
./gradlew :app:assembleDebug
```

默认 mock baseURL：

```text
https://m1.apifoxmock.com/m1/3174267-1700689-default
```

如需覆盖：

```bash
./gradlew :app:assembleDebug -PAI_DATA_INSIGHT_BASE_URL=https://your-base-url
```

## 契约生成

Android 跨端模型由根目录契约生成：

```bash
./scripts/generate-cross-platform-contracts.sh
```

生成目标：

```text
app-android/core/model/src/main/java/com/aidatainsight/android/core/model/contract/ContractModels.kt
```

如果发现模型、字段、接口形态不对，先改 `docs/cross-platform/contracts`，再重新生成，不要直接手改生成文件。

## 开发规则

- 新功能先读 `../docs/ai-generation-guide.md`。
- UI layout 先读对应的 `../docs/cross-platform/contracts/ui-layout/*.yaml`。
- Repository 不硬编码完整 URL，子模块 path 放在对应 remote service / API descriptor 语义里。
- UseCase 返回 application output，不返回 Compose UI model。
- UI 只消费本端 UI State，不直接解析 DTO 或接口 JSON。
- 背景、蒙层、safe area、键盘避让要按 layout 契约处理，不能只看某一端截图。

## 常用检查

```bash
cd app-android
./gradlew :app:assembleDebug
./gradlew :core:network:testDebugUnitTest
./gradlew :feature:ai-chat:testDebugUnitTest
```

根目录契约校验：

```bash
./scripts/validate-cross-platform-contracts.sh
```
