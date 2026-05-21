//
//  AIDataInsightAppleApp.swift
//  AIDataInsightApple
//
//  Created by Janlor on 5/19/26.
//

import SwiftUI

@main
struct AIDataInsightAppleApp: App {
    @State private var appEnvironment = AppRuntimeEnvironment(
        usePreviewRepositories: CommandLine.arguments.contains("--ui-testing")
    )

    var body: some Scene {
        AppScene(environment: appEnvironment)
    }
}
