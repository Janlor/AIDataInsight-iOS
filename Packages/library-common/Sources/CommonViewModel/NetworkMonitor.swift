//
//  NetworkMonitor.swift
//  LibraryCommon
//
//  Created by Janlor on 4/22/26.
//

import Foundation
import Networking

public protocol NetworkReachabilityProviding: AnyObject {
    var isReachable: Bool { get }
    func startMonitoring(_ onChange: @escaping (Bool) -> Void)
    func stopMonitoring()
}

public final class NetworkMonitor {

    public static let shared = NetworkMonitor()

    private var provider: NetworkReachabilityProviding?
    private var observers: [UUID: (Bool) -> Void] = [:]

    private init() {}

    public func setup(provider: NetworkReachabilityProviding) {
        self.provider = provider
        startMonitoring { [weak self] reachable in
            self?.notifyAll(reachable)
        }
    }

    public var isReachable: Bool {
        provider?.isReachable ?? false
    }
    
    public func startMonitoring(_ onChange: @escaping (Bool) -> Void) {
        provider?.startMonitoring(onChange)
    }

    public func stopMonitoring() {
        provider?.stopMonitoring()
    }
    
    // MARK: - Observer

    @discardableResult
    public func addObserver(_ observer: @escaping (Bool) -> Void) -> UUID {
        let id = UUID()
        observers[id] = observer
        return id
    }

    public func removeObserver(_ id: UUID) {
        observers.removeValue(forKey: id)
    }

    private func notifyAll(_ reachable: Bool) {
        observers.values.forEach { $0(reachable) }
    }
}

extension NetworkReachabilityAdapter: NetworkReachabilityProviding {
    
    public func startMonitoring(_ onChange: @escaping (Bool) -> Void) {
        startListening { adapter in
            onChange(adapter.isReachable)
        }
    }
    
    public func stopMonitoring() {
        stopListening()
    }
}
