//
//  UIView+Empty.swift
//  LibraryCommon
//
//  Created by Janlor on 4/22/26.
//

import UIKit
import ObjectiveC.runtime

private var kEmptyViewKey: UInt8 = 0

public extension UIView {

    var emptyView: EmptyView? {
        get {
            return objc_getAssociatedObject(self, &kEmptyViewKey) as? EmptyView
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &kEmptyViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
                self.subviews.forEach { view in
                    if view.isKind(of: type(of: newValue)) {
                        view.removeFromSuperview()
                    }
                }
                
                self.addSubview(newValue)
                newValue.translatesAutoresizingMaskIntoConstraints = false
                newValue.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
                newValue.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
//                NSLayoutConstraint.activate([
//                    NSLayoutConstraint(item: newValue, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0),
//                    NSLayoutConstraint(item: newValue, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0),
//                    NSLayoutConstraint(item: newValue, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0/3.0, constant: 1)
//                ])
                newValue.isHidden = true
            }
        }
    }
    
    func showState(_ state: EmptyViewState) {
        switch state {
        case .idle:
            hideEmpty()
        case .loading:
            startLoading()
        case .empty:
            showEmpty()
        case .error:
            showError()
        }
    }
    
    func startLoading(message: String? = nil) {
        guard !(self is EmptyView) else {
            assertionFailure("EmptyView及其子类不能调用startLoading方法")
            return
        }
        
        self.emptyView?.isHidden = false
        let msg = message ?? NSLocalizedString("正在载入", bundle: .module, comment: "")
        self.emptyView?.setState(.loading, message: msg)
        if let emptyView = self.emptyView {
            self.bringSubviewToFront(emptyView)
        }
    }
    
    func endLoading() {
        hideEmpty()
    }
    
    func showEmpty(message: String? = nil, image: UIImage? = nil, imgSize: CGSize? = nil) {
        guard !(self is EmptyView) else {
            assertionFailure("EmptyView及其子类不能调用showEmpty方法")
            return
        }
        let msg = message ?? NSLocalizedString("暂无数据", bundle: .module, comment: "")
        let img = image ?? UIImage.imageNamed(for: "empty_data")
        self.emptyView?.isHidden = false
        self.emptyView?.setState(.empty, message: msg, image: img, imgSize: imgSize)
        if let emptyView = self.emptyView {
            self.bringSubviewToFront(emptyView)
        }
    }
    
    func showError(message: String? = nil, image: UIImage? = nil, imgSize: CGSize? = nil) {
        guard !(self is EmptyView) else {
            assertionFailure("EmptyView及其子类不能调用showError方法")
            return
        }
        let msg = message ?? NSLocalizedString("暂无网络", bundle: .module, comment: "")
        let img = image ?? UIImage.imageNamed(for: "empty_network")
        self.emptyView?.isHidden = false
        self.emptyView?.setState(.error, message: msg, image: img, imgSize: imgSize)
        if let emptyView = self.emptyView {
            self.bringSubviewToFront(emptyView)
        }
    }
    
    func hideEmpty() {
        guard !(self is EmptyView) else {
            assertionFailure("EmptyView及其子类不能调用hideError方法")
            return
        }
        self.emptyView?.isHidden = true
        self.emptyView?.setState(.idle)
    }
}
