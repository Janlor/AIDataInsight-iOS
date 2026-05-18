import Testing
@testable import AppCore

@Test func appEnvironmentKeepsExpectedOrder() {
    #expect(AppEnvironment.allCases == [.mock, .local, .dev, .test, .pre, .prod])
}

