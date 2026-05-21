//
//  AppScene.swift
//  AIDataInsightApple
//
//  Created by Codex on 5/19/26.
//

import SwiftUI
#if os(macOS)
import FeaturePrivacy
import FeatureSetting
#endif

struct AppScene: Scene {
    let environment: AppRuntimeEnvironment

    var body: some Scene {
        WindowGroup {
            RootView(environment: environment)
        }
#if os(macOS)
        .defaultSize(width: 1280, height: 820)
#endif
        .commands {
            AppCommands()
        }
#if os(macOS)
        Settings {
            MacSettingsView(environment: environment)
        }
#endif
    }
}

#if os(macOS)
private struct MacSettingsView: View {
    @Bindable var environment: AppRuntimeEnvironment
    @State private var path: [MacSettingsRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            SettingScreen(
                store: environment.settingStore,
                onOpenPrivacy: {
                    path.append(.privacy)
                },
                showsLogoutAction: false
            )
            .navigationDestination(for: MacSettingsRoute.self) { route in
                switch route {
                case .privacy:
                    PrivacyScreen()
                }
            }
        }
        .frame(minWidth: 500, minHeight: 540)
    }
}

private enum MacSettingsRoute: Hashable {
    case privacy
}
#endif
