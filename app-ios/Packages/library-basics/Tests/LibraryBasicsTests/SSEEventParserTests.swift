import Testing
@testable import Networking

struct SSEEventParserTests {
    @Test
    func consume_multipleDataLines_emitsJoinedPayload() {
        var parser = SSEEventParser()

        #expect(parser.consume(line: "event: message") == nil)
        #expect(parser.consume(line: "data: hello") == nil)
        #expect(parser.consume(line: "data: world") == nil)

        let payload = parser.consume(line: "")

        #expect(payload == "hello\nworld")
    }

    @Test
    func finish_emitsPendingPayload() {
        var parser = SSEEventParser()
        #expect(parser.consume(line: "data: tail") == nil)

        let payload = parser.finish()

        #expect(payload == "tail")
    }

    @Test
    func consume_commentOrEmptyPacket_ignoresIt() {
        var parser = SSEEventParser()

        #expect(parser.consume(line: ": ping") == nil)
        #expect(parser.consume(line: "") == nil)
    }
}
