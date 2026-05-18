# AIDataInsight Apple

`app-apple` is the modern Apple-platform implementation of AIDataInsight.

It is not a migration of the UIKit-based `app-ios` target. The project is built from the shared cross-platform contracts and is intended to demonstrate a contemporary Apple stack for iOS 17+, iPadOS 17+, macOS 14+, and visionOS 1.0+.

## Stack

- SwiftUI
- Observation
- Swift Concurrency
- SwiftData
- Keychain for sensitive session storage
- Swift Charts
- Swift Testing
- XCTest UI Tests
- Swift Package Manager

## Structure

```text
app-apple/
  README.md
  AIDataInsightApple/
    AIDataInsightApple.xcodeproj
    AIDataInsightApple/
    AIDataInsightAppleTests/
    AIDataInsightAppleUITests/
    Packages/
      AppCore/
      AppContracts/
      AppDesignSystem/
      AppNetworking/
      AppPersistence/
      AppAccount/
      FeatureLogin/
      FeatureAIChat/
      FeatureHistory/
      FeatureSetting/
      FeaturePrivacy/
      AppTestingSupport/
```

## Phase 0 Status

The Xcode shell app has been normalized for the planned platform baseline:

- iOS deployment target: 17.0
- macOS deployment target: 14.0
- visionOS deployment target: 1.0
- Swift language version: 6.0
- Local Swift packages are scaffolded and referenced by the app target.
- The template SwiftData `Item` sample has been removed.
- The app now starts from a package-backed SwiftUI shell.

## Validation

The current command-line environment may need a full Xcode developer directory selected before `xcodebuild` works:

```sh
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

With the full Xcode 26.5 developer directory selected, validate from Xcode first. In this Codex command-line environment, SwiftPM source targets were validated with an explicit temporary module cache and SwiftPM sandbox disabled:

```sh
cd app-apple/AIDataInsightApple/Packages/AppCore
env SWIFTPM_MODULECACHE_PATH=/private/tmp/app-apple-swiftpm-module-cache \
  CLANG_MODULE_CACHE_PATH=/private/tmp/app-apple-clang-module-cache \
  swift build --disable-sandbox
```

Swift Testing and app-level UI tests should be validated from Xcode 26.5 until the command-line Xcode developer directory is configured.

## Architecture Plan

See:

- [docs/architecture/apple-platform-implementation-plan.md](../docs/architecture/apple-platform-implementation-plan.md)
