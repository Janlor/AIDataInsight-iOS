import Foundation
import Testing
@testable import AppTestingSupport

@Test func fixtureLoaderStoresRootURL() {
    let url = URL(filePath: "/tmp/contracts")
    let loader = FixtureLoader(rootURL: url)
    #expect(loader.rootURL == url)
}

