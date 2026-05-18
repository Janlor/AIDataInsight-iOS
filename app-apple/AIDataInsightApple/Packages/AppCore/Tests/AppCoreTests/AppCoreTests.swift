import Testing
@testable import AppCore

@Test func appEnvironmentKeepsExpectedOrder() {
    #expect(AppEnvironment.allCases == [.mock, .local, .dev, .test, .pre, .prod])
}

@Test func mockEnvironmentUsesSharedApifoxHost() {
    #expect(APIEnvironment.mock.baseURL.absoluteString == "https://m1.apifoxmock.com/m1/3174267-1700689-default")
}
