//
//  MenuViewController.swift
//  ModuleAI
//
//  Created by Janlor on 2024/10/29.
//

import UIKit
import BaseKit
import BaseUI

public struct MenuItem: Hashable {
    let title: String?
    let image: UIImage?
    /// 唯一标识
    private var identifier = UUID()
    
    public init(title: String? = nil, image: UIImage? = nil, identifier: UUID = UUID()) {
        self.title = title
        self.image = image
        self.identifier = identifier
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

public class MenuViewController: UIViewController {
    // 单例实现
    static let shared = MenuViewController()
    
    private lazy var stackView: PanSelectionStackView = {
        let stack = PanSelectionStackView()
        stack.axis = .horizontal
        stack.spacing = 0
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var viewManager: DynamicViewManager<MenuItem, ImageTextButton>!
    
    // 添加一个标记当前是否显示
    private(set) var isShowing = false
    
    // 私有化初始化方法，防止外部创建实例
    private override init(nibName: String? = nil, bundle: Bundle? = nil) {
        super.init(nibName: nibName, bundle: bundle)
        modalPresentationStyle = .popover
        preferredContentSize = CGSize(width: 76, height: 76)
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        viewManager = DynamicViewManager(container: stackView,
                                         createView: createChildView,
                                         setupView: setupChildView(_:_:),
                                         extraSetup: extraSetupView(_:_:))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isShowing = false
        menuItems = []
        didSelectIndex = nil
    }
    
    // 属性声明
    var menuItems: [MenuItem] = [] {
        didSet { viewManager.setupModels(menuItems) }
    }
    var didSelectIndex: ((Int) -> Void)?
    
    // 显示菜单的便利方法
    func show(from sourceView: UIView, 
             in viewController: UIViewController,
             items: [MenuItem],
             didSelect: @escaping (Int) -> Void) {
        menuItems = items
        didSelectIndex = didSelect
        
        let width = 76 * items.count
        preferredContentSize = CGSize(width: width, height: 76)
        
        if let popover = popoverPresentationController {
            popover.delegate = viewController as? UIPopoverPresentationControllerDelegate
            popover.sourceView = sourceView
            popover.sourceRect = sourceView.bounds
            
            // 计算可用空间
            let sourceRect = sourceView.convert(sourceView.bounds, to: viewController.view)
            let safeAreaInsets = viewController.view.safeAreaInsets
            let spaceBelow = viewController.view.bounds.height - sourceRect.maxY - safeAreaInsets.bottom
            let spaceAbove = sourceRect.minY - safeAreaInsets.top
            
            if spaceBelow >= preferredContentSize.height {
                popover.permittedArrowDirections = .up
            } else if spaceAbove >= preferredContentSize.height {
                popover.permittedArrowDirections = .down
            } else {
                popover.permittedArrowDirections = [.left, .right]
            }
            
            popover.canOverlapSourceViewRect = false
            popover.popoverBackgroundViewClass = MenuBackgroundView.self
        }
        
        // 检查当前显示状态
        if isShowing {
            // 如果已经显示，只更新位置和内容
            popoverPresentationController?.sourceView = sourceView
            popoverPresentationController?.sourceRect = sourceView.bounds
            
            // 更新视图布局
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                options: [.beginFromCurrentState, .curveEaseInOut],
                animations: {
                    self.popoverPresentationController?.sourceView = sourceView
                    self.popoverPresentationController?.sourceRect = sourceView.bounds
                    self.view.layoutIfNeeded()
                }
            )
        } else if presentingViewController == nil {
            // 只有在没有被present的情况下才present
            viewController.present(self, animated: true) {
                self.isShowing = true
            }
        }
    }
}

extension MenuViewController {
    private func createChildView() -> ImageTextButton {
        let view = ImageTextButton(type: .system)
        view.imagePosition = .top
        view.imageTextSpacing = 4
        view.contentInsets = UIEdgeInsets(horizontal: 50, vertical: 30)
        view.tintColor = .white
        view.setTitleColor(.white, for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        view.addTarget(self, action: #selector(didClickedImageTextButton(_:)), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private func setupChildView(_ view: ImageTextButton, _ model: MenuItem) {
        view.setTitle(model.title, for: .normal)
        view.setImage(model.image, for: .normal)
    }
    
    private func extraSetupView(_ view: ImageTextButton, _ index: Int) {
        view.tag = index
    }
    
    @objc func didClickedImageTextButton(_ sender: UIButton) {
        guard sender.tag < menuItems.count else { return }
        // 保存回调，因为 dismiss 后会被清空
        let callback = didSelectIndex
        
        dismiss(animated: true) {
            if let callback = callback {
                callback(sender.tag)
            }
        }
    }
}
