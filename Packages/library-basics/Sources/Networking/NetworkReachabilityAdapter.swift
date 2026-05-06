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
    
    private var monitor: NWPathMonitor?
    private let monitorQueue = DispatchQueue(label: "com.aidatainsight.network.reachability")
    private var isMonitoring = false
    private var listener: ListenerCallBack?
    private var currentStatus: NWPath.Status = .requiresConnection
    
    @objc
    /// 是否网络可达
    open var isReachable: Bool {
        currentStatus == .satisfied
    }
    
    @objc
    open func startListening(_ callBack: @escaping ListenerCallBack) {
        listener = callBack

        guard isMonitoring == false else {
            callBack(self)
            return
        }

        isMonitoring = true
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            self.currentStatus = path.status
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
