//
//  NetworkReachabilityAdapter.swift
//  LibraryBasics
//
//  Created by Janlor on 2024/5/22.
//

import Foundation
import Network

@objc
/// 对系统 Network.NWPathMonitor 进行了一层转发
open class NetworkReachabilityAdapter: NSObject {
    public typealias ListenerCallBack = (NetworkReachabilityAdapter) -> Void

    enum ReachabilityStatus {
        case satisfied
        case requiresConnection
        case unsatisfied
    }

    protocol PathMonitoring: AnyObject {
        var pathUpdateHandler: ((ReachabilityStatus) -> Void)? { get set }
        func start(queue: DispatchQueue)
        func cancel()
    }

    private final class NWPathMonitorAdapter: PathMonitoring {
        private let monitor = NWPathMonitor()
        var pathUpdateHandler: ((ReachabilityStatus) -> Void)?

        init() {
            monitor.pathUpdateHandler = { [weak self] path in
                self?.pathUpdateHandler?(Self.map(path.status))
            }
        }

        func start(queue: DispatchQueue) {
            monitor.start(queue: queue)
        }

        func cancel() {
            monitor.cancel()
        }

        private static func map(_ status: NWPath.Status) -> ReachabilityStatus {
            switch status {
            case .satisfied:
                return .satisfied
            case .requiresConnection:
                return .requiresConnection
            default:
                return .unsatisfied
            }
        }
    }

    private var monitor: PathMonitoring?
    private let monitorQueue = DispatchQueue(label: "com.aidatainsight.network.reachability")
    private let monitorFactory: () -> PathMonitoring
    private var isMonitoring = false
    private var listener: ListenerCallBack?
    private var currentStatus: ReachabilityStatus = .requiresConnection

    override public init() {
        self.monitorFactory = { NWPathMonitorAdapter() }
        super.init()
    }

    init(monitorFactory: @escaping () -> PathMonitoring) {
        self.monitorFactory = monitorFactory
        super.init()
    }

    @objc
    /// 是否网络可达
    open var isReachable: Bool {
        switch currentStatus {
        case .satisfied:
            return true
        case .requiresConnection, .unsatisfied:
            return false
        }
    }

    @objc
    open func startListening(_ callBack: @escaping ListenerCallBack) {
        listener = callBack

        guard isMonitoring == false else {
            callBack(self)
            return
        }

        isMonitoring = true
        let monitor = monitorFactory()
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            self.currentStatus = path
            DispatchQueue.main.async {
                self.listener?(self)
            }
        }
        self.monitor = monitor
        monitor.start(queue: monitorQueue)
        DispatchQueue.main.async {
            callBack(self)
        }
    }
    
    @objc
    open func stopListening() {
        guard isMonitoring else { return }
        isMonitoring = false
        listener = nil
        monitor?.cancel()
        monitor = nil
    }
    
    deinit {
        stopListening()
    }
}
