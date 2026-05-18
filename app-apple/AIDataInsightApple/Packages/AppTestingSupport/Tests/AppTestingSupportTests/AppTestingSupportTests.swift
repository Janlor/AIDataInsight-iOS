import Foundation
import Testing
@testable import AppTestingSupport

@Test func fixtureLoaderStoresRootURL() {
    let url = URL(filePath: "/tmp/contracts")
    let loader = FixtureLoader(rootURL: url)
    #expect(loader.rootURL == url)
}

@Test func fixtureLoaderReportsMissingFixture() throws {
    let loader = FixtureLoader(rootURL: URL(filePath: "/tmp/contracts"))
    #expect(throws: FixtureLoaderError.missingFixture("missing.json")) {
        try loader.data(at: "missing.json")
    }
}
