//
//  AIDataInsightAppleApp.swift
//  AIDataInsightApple
//
//  Created by Janlor on 5/19/26.
//

import SwiftUI

@main
struct AIDataInsightAppleApp: App {
    @State private var appEnvironment = AppRuntimeEnvironment()

    var body: some Scene {
        AppScene(environment: appEnvironment)
    }
}
