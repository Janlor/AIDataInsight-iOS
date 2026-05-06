import Foundation
import Testing
@testable import Networking

@Suite(.serialized)
struct NetworkClientTests {
    @Test
    func send_returnsDataAndHTTPResponse() async throws {
        defer { MockURLProtocol.requestHandler = nil }
        let url = try #require(URL(string: "https://example.com/ping"))
        let request = URLRequest(url: url)
        MockURLProtocol.requestHandler = { request in
            #expect(request.url?.absoluteString == "https://example.com/ping")
            let requestURL = try #require(request.url)
            let response = try #require(
                HTTPURLResponse(
                    url: requestURL,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: ["X-Test": "1"]
                )
            )
            return (response, Data("pong".utf8))
        }

        let client = URLSessionNetworkClient(session: makeMockedSession())
        let result = try await client.send(request)

        #expect(result.response.statusCode == 200)
        #expect(result.response.value(forHTTPHeaderField: "X-Test") == "1")
        #expect(String(decoding: result.data, as: UTF8.self) == "pong")
    }

    @Test
    func send_transportError_throwsUnderlyingError() async {
        defer { MockURLProtocol.requestHandler = nil }
        let request = URLRequest(url: URL(string: "https://example.com/ping")!)
        MockURLProtocol.requestHandler = { request in
            throw URLError(.timedOut)
        }

        let client = URLSessionNetworkClient(session: makeMockedSession())

        await #expect(throws: URLError.self) {
            _ = try await client.send(request)
        }
    }
}

private func makeMockedSession() -> URLSession {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [MockURLProtocol.self]
    return URLSession(configuration: configuration)
}

private final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (URLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
