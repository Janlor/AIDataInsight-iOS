import Foundation
import Testing
@testable import Networking

struct RequestBuilderTests {
    private let builder = RequestBuilder()

    @Test
    func buildRequest_plainRequest_setsMethodHeadersAndURL() throws {
        let target = MockTarget(
            baseURL: URL(string: "https://example.com")!,
            path: "/ping",
            method: Networking.Method.get,
            parameters: [:],
            task: Networking.Task.requestPlain,
            headers: ["X-Test": "1"]
        )

        let request = try builder.buildRequest(from: target)

        #expect(request.httpMethod == "GET")
        #expect(request.url?.absoluteString == "https://example.com/ping")
        #expect(request.value(forHTTPHeaderField: "X-Test") == "1")
    }

    @Test
    func buildRequest_getParameters_encodesQueryString() throws {
        let target = MockTarget(
            baseURL: URL(string: "https://example.com")!,
            path: "/history",
            method: Networking.Method.get,
            parameters: ["page": 2, "size": 20],
            task: Networking.Task.requestParameters(
                parameters: ["page": 2, "size": 20],
                encoding: URLEncoding.queryString
            ),
            headers: nil as [String: String]?
        )

        let request = try builder.buildRequest(from: target)

        let url = try #require(request.url?.absoluteString)
        #expect(url.contains("page=2"))
        #expect(url.contains("size=20"))
        #expect(request.httpBody == nil)
    }

    @Test
    func buildRequest_postParameters_encodesJsonBody() throws {
        let target = MockTarget(
            baseURL: URL(string: "https://example.com")!,
            path: "/login",
            method: Networking.Method.post,
            parameters: ["name": "demo", "pwd": "123456"],
            task: Networking.Task.requestParameters(
                parameters: ["name": "demo", "pwd": "123456"],
                encoding: JSONEncoding.prettyPrinted
            ),
            headers: ["Content-Type": "application/json"]
        )

        let request = try builder.buildRequest(from: target)
        let body = try #require(request.httpBody)
        let object = try #require(try JSONSerialization.jsonObject(with: body) as? [String: Any])

        #expect(request.httpMethod == "POST")
        #expect(object["name"] as? String == "demo")
        #expect(object["pwd"] as? String == "123456")
    }

    @Test
    func buildRequest_uploadFile_throwsUnsupportedTask() {
        let target = MockTarget(
            baseURL: URL(string: "https://example.com")!,
            path: "/upload",
            method: Networking.Method.post,
            parameters: [:],
            task: Networking.Task.uploadFile(URL(fileURLWithPath: "/tmp/demo.txt")),
            headers: nil as [String: String]?
        )

        #expect(throws: RequestBuilderError.self) {
            _ = try builder.buildRequest(from: target)
        }
    }
}

private struct MockTarget: CustomTargetType {
    let baseURL: URL
    let path: String
    let method: Networking.Method
    let parameters: [String : Any]
    let task: Networking.Task
    let headers: [String : String]?
    let sampleData: Data = Data()
}
