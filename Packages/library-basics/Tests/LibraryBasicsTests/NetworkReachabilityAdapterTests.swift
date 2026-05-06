import Foundation
import Testing
@testable import Networking

@Suite(.serialized)
struct NetworkReachabilityAdapterTests {
    @Test
    func startListening_reportsReachableStateChanges() async {
        let monitor = MockPathMonitor()
        let adapter = NetworkReachabilityAdapter {
            monitor
        }
        let recorder = ReachabilityRecorder()

        adapter.startListening { adapter in
            _Concurrency.Task {
                await recorder.append(adapter.isReachable)
            }
        }

        monitor.send(.satisfied)
        await recorder.waitForCount(2)
        monitor.send(.unsatisfied)
        await recorder.waitForCount(3)

        let values = await recorder.values
        #expect(values.contains(true))
        #expect(values.contains(false))
    }

    @Test
    func stopListening_cancelsMonitor() {
        let monitor = MockPathMonitor()
        let adapter = NetworkReachabilityAdapter {
            monitor
        }

        adapter.startListening { _ in }
        adapter.stopListening()

        #expect(monitor.cancelCallCount == 1)
    }
}

private final class MockPathMonitor: NetworkReachabilityAdapter.PathMonitoring {
    var pathUpdateHandler: ((NetworkReachabilityAdapter.ReachabilityStatus) -> Void)?
    var cancelCallCount = 0

    func start(queue: DispatchQueue) {}

    func cancel() {
        cancelCallCount += 1
    }

    func send(_ status: NetworkReachabilityAdapter.ReachabilityStatus) {
        pathUpdateHandler?(status)
    }
}

private actor ReachabilityRecorder {
    private(set) var values: [Bool] = []

    func append(_ value: Bool) {
        values.append(value)
    }

    func waitForCount(_ expectedCount: Int) async {
        while values.count < expectedCount {
            await _Concurrency.Task.yield()
        }
    }
}
