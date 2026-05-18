//
//  AppScene.swift
//  AIDataInsightApple
//
//  Created by Codex on 5/19/26.
//

import SwiftUI

struct AppScene: Scene {
    let environment: AppRuntimeEnvironment

    var body: some Scene {
        WindowGroup {
            RootView(environment: environment)
        }
#if os(macOS)
        .defaultSize(width: 1120, height: 760)
#endif
        .commands {
            AppCommands()
        }
    }
}
