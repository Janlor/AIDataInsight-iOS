//
//  ContainerViewController.swift
//  ModuleAI
//
//  Created by Janlor on 4/23/26.
//

import UIKit
import BaseUI

class ContainerViewController: UIViewController {
    
    private lazy var mainVC: AIChatViewController = {
        let vc = AIChatViewController()
        vc.didClickedMoreMenu = { [weak self] sender in
            self?.openMenu()
        }
        return vc
    }()
    
    private lazy var menuVC: HistoryViewController = {
        let vc = HistoryViewController()
        vc.openHistoryClosure = { [weak self] historyId in
            self?.mainVC.loadConversation(historyId)
            self?.closeMenu()
        }
        return vc
    }()
    
    private lazy var mainNav: BaseNavigationController = {
        return BaseNavigationController(rootViewController: mainVC)
    }()
    
    private lazy var menuNav: BaseNavigationController = {
        return BaseNavigationController(rootViewController: menuVC)
    }()
    
    private var isOpen = false {
        didSet {
            if isOpen {
                menuVC.reloadData()
            }
        }
    }
    
    private var startX: CGFloat = 0
    private var animator: UIViewPropertyAnimator?
    
    private var isMainInputing: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGesture()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // menu
        addChild(menuNav)
        view.addSubview(menuNav.view)
        menuNav.view.frame = view.bounds
        menuNav.didMove(toParent: self)
        
        // 初始位置
        menuNav.view.transform = CGAffineTransform(translationX: -view.bounds.width * 0.5, y: 0)
        
        // main
        addChild(mainNav)
        view.addSubview(mainNav.view)
        mainNav.view.frame = view.bounds
        mainNav.didMove(toParent: self)
        
        // 阴影
        mainNav.view.layer.shadowColor = UIColor.black.cgColor
        mainNav.view.layer.shadowOpacity = 0.2
        mainNav.view.layer.shadowRadius = 10
        if #available(iOS 26.0, *) {
            mainNav.view.cornerConfiguration = .corners(radius: .containerConcentric())
        }
    }
    
    private func setupGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        view.addGestureRecognizer(pan)
    }
    
    @objc private func handlePan(_ pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: view).x
        
        switch pan.state {
            
        case .began:
            startX = currentMainX()
            
            // 打断正在进行的动画，并同步到当前状态
            animator?.stopAnimation(true)
            animator = nil
            
            // 关闭键盘
            if mainNav.view.transform.tx == 0 {
                isMainInputing = mainVC.isInputing()
                view.endEditing(true)
            }
            
        case .changed:
            var newX = startX + translation
            newX = min(max(newX, 0), view.bounds.width)
            
            updateUI(x: newX) // 手势阶段直接改 UI
            
        case .ended, .cancelled:
            let velocity = pan.velocity(in: view).x
            let currentX = currentMainX()
            
            let shouldOpen: Bool
            
            if abs(velocity) > 500 {
                shouldOpen = velocity > 0
            } else {
                shouldOpen = currentX > view.bounds.width * 0.5
            }
            
            animate(to: shouldOpen ? view.bounds.width : 0, velocity: velocity) { [weak self] in
                guard let self = self else { return }
                
                // 关闭后恢复键盘
                if !self.isOpen, self.isMainInputing {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        self.mainVC.focusInput()
                    }
                }
            }
            
            isOpen = shouldOpen
            
        default:
            break
        }
    }
    
    private func updateUI(x: CGFloat) {
        let roundedX = round(x)
        
        // 主界面
        mainNav.view.transform = CGAffineTransform(translationX: roundedX, y: 0)
        
        // menu（半速视差）
        let menuX = -view.bounds.width + roundedX
        menuNav.view.transform = CGAffineTransform(translationX: menuX * 0.5, y: 0)
    }
    
    private func animate(to targetX: CGFloat, velocity: CGFloat, completion: (() -> Void)? = nil) {
        animator?.stopAnimation(true)
        
        let currentX = currentMainX()
        let distance = abs(targetX - currentX)
        
        // 根据距离动态算时长
        let duration = min(max(Double(distance / view.bounds.width) * 0.25, 0.1), 0.25)
        
        animator = UIViewPropertyAnimator(duration: duration, curve: .easeOut) {
            self.updateUI(x: targetX)
        }
        
        animator?.addCompletion { _ in
            completion?()   // 动画结束回调
        }
        
        animator?.startAnimation()
    }
    
    private func currentMainX() -> CGFloat {
        return mainNav.view.transform.tx
    }
    
    private func openMenu() {
        animate(to: view.bounds.width, velocity: 0) { [weak self] in }
        isOpen = true
    }
    
    private func closeMenu() {
        animate(to: 0, velocity: 0) { [weak self] in }
        isOpen = false
    }
}

