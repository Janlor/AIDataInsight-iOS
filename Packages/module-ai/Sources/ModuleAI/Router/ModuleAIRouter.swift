//
//  ModuleAIRouter.swift
//  ModuleAI
//
//  Created by Janlor on 4/22/26.
//

import UIKit
import Router
import ProtocolAI

struct ModuleAIRouter: RouterService {
    
}

extension ModuleAIRouter: RouterDestination {
    func to(_ arg: [AnyHashable : Any]?, _ closure: ((Any, [AnyHashable : Any]?) -> Void)?) -> UIViewController {
        let vc = AIChatViewController()
        return vc
    }
}

extension ModuleAIRouter: ProtocolAI {
    
}
