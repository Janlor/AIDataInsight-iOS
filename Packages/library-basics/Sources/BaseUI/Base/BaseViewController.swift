//
//  BaseViewController.swift
//  LibraryCommon
//
//  Created by Janlor on 4/22/26.
//

import UIKit
//import IQKeyboardManagerSwift

open class BaseViewController: UIViewController, LayoutContainer, Quitable {
    /// 渐变色背景
    private var gradientBgLayer: CAGradientLayer?
    
    open override var shouldAutorotate: Bool {
        if traitCollection.horizontalSizeClass == .regular {
            return true
        }
        return false
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if traitCollection.horizontalSizeClass == .regular {
            return .all
        }
        return .portrait
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .theme.background
        setupUI()
        setupData()
        horizontalSizeClassDidChange()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        IQKeyboardManager.shared.isEnabled = false
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if navigationController?.viewControllers.first !== self {
            navigationController?.interactivePopGestureRecognizer?.delegate = self
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        IQKeyboardManager.shared.isEnabled = false
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass {
            horizontalSizeClassDidChange()
        }
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard gradientBgLayer != nil else { return }
        setupBackground(size)
    }
    
    // 在该方法中设置视图
    open func setupUI() { }
    
    // 在该方法中设置数据
    open func setupData() {}
    
    open func setupBackground(_ size: CGSize? = nil) {
        view.backgroundColor = UIColor.theme.groupedBackground
        
        if let layer = gradientBgLayer {
            layer.removeFromSuperlayer()
            gradientBgLayer = nil
        }
        let bgColors: [UIColor] = [
            UIColor(appHex: 0x3478F6).withAlphaComponent(0.06),
            UIColor(appHex: 0x3478F6).withAlphaComponent(0.01),
            UIColor(appHex: 0x3478F6).withAlphaComponent(0.01),
            UIColor(appHex: 0x3478F6).withAlphaComponent(0.06)
        ]
        let frame: CGRect? = size != nil ? CGRect(origin: .zero, size: size!) : nil
        gradientBgLayer = view.app.gradientLayer(colors: bgColors, locations: [0, 0.3, 0.7, 1], frame: frame, startPoint: CGPoint(x: 0.3, y: 0), endPoint: CGPoint(x: 0.7, y: 1))
        view.layer.insertSublayer(gradientBgLayer!, at: 0)
    }
    
    func horizontalSizeClassDidChange() {
        guard #available(iOS 14.0, *) else { return }
        switch traitCollection.horizontalSizeClass {
        case .compact:
            navigationItem.backButtonDisplayMode = .minimal
        default:
            navigationItem.backButtonDisplayMode = .default
        }
    }
    
    deinit {
        appLog("已被销毁")
    }
}

extension UIViewController {
    public func pushToVC(_ vc: UIViewController?) {
        guard let vc = vc else { return }
        guard let nav = navigationController else { return }
        nav.pushViewController(vc, animated: true)
    }
    
    public func presentToVC(_ vc: UIViewController?) {
        guard let vc = vc else { return }
        present(vc, animated: true)
    }
}

/// 给UIViewController默认实现右滑返回的代理
extension UIViewController: @retroactive UIGestureRecognizerDelegate {
    
}

/// 布局相关的方法
public protocol LayoutContainer: AnyObject {
    
    // 在该方法中设置视图
    func setupUI()
    
    // 在该方法中设置数据
    func setupData()
}

/// 关闭页面协议
public protocol Quitable: UIViewController {
    
    /// 退出页面
    func quit()
}

// MARK: - Can Not Override Functions

extension Quitable {
    /// 退出页面
    public func quit() {        
        if let presenting = presentingViewController {
            presenting.dismiss(animated: true, completion: nil)
        } else if let nav = navigationController {
            guard let _ = nav.popViewController(animated: true) else {
                nav.dismiss(animated: true, completion: nil)
                return
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}
