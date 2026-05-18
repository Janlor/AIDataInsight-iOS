//
//  AIDataInsightAppleTests.swift
//  AIDataInsightAppleTests
//
//  Created by Janlor on 5/19/26.
//

import Testing
import AppCore
@testable import AIDataInsightApple

struct AIDataInsightAppleTests {

    @MainActor
    @Test func appRuntimeEnvironmentStartsInMock() async throws {
        let environment = AppRuntimeEnvironment()
        #expect(environment.appEnvironment == .mock)
    }

}
