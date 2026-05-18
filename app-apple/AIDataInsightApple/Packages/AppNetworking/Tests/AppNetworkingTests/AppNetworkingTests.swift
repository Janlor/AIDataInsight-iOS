import Testing
@testable import AppNetworking

@Test func httpRequestDefaultsToGet() {
    let request = HTTPRequest(path: "/oauth2/login")
    #expect(request.method == .get)
    #expect(request.path == "/oauth2/login")
}

