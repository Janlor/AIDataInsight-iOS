import Foundation

public protocol AppClock: Sendable {
    func now() -> Date
}

public struct SystemAppClock: AppClock {
    public init() {}

    public func now() -> Date {
        Date()
    }
}

public struct FixedAppClock: AppClock {
    private let date: Date

    public init(date: Date) {
        self.date = date
    }

    public func now() -> Date {
        date
    }
}
