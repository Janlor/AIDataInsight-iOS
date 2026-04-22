//
//  NetworkReachabilityAdapter.swift
//  Network
//
//  Created by Janlor on 2024/5/22.
//

import Foundation
import Alamofire

@objc
/// 对Alamofire的NetworkReachabilityManager进行了一层转发
open class NetworkReachabilityAdapter: NSObject {
    
    public typealias ListenerCallBack = (NetworkReachabilityAdapter) -> Void
    
    fileprivate lazy var manager: NetworkReachabilityManager? = NetworkReachabilityManager()
    
    @objc
    /// 是否网络可达
    open var isReachable: Bool {
        manager?.isReachable ?? false
    }
    
    @objc
    open func startListening(_ callBack: @escaping ListenerCallBack) {
        manager?.startListening(onUpdatePerforming: {[weak self] status in
            guard let current = self else {
                return
            }
            callBack(current)
        })
    }
    
    @objc
    open func stopListening() {
        manager?.stopListening()
    }
    
    deinit {
        stopListening()
    }
    
}
