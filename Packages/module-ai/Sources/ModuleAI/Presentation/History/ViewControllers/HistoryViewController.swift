//
//  HistoryViewController.swift
//  ModuleAI
//
//  Created by Janlor on 2024/10/24.
//

import UIKit
import BaseUI
import SwifterSwift
import Router
import SettingProtocol

extension Notification.Name {
    static let historyDidDeleteAll = Notification.Name("AI.HistoryDidDeleteAllNotification")
    static let historyDidDeleteChat = Notification.Name("AI.HistoryDidDeleteChatNotification")
}

class HistoryViewController: BaseViewController {
    /// 打开历史会话
    var openHistoryClosure: ((Int?) -> Void)?
    
    private let viewModel = HistoryViewModel()
    private var loadTask: Task<Void, Never>?
    private var deleteTask: Task<Void, Never>?
    
    private var tableView: UITableView!
    
    /// 添加属性保存当前长按的 indexPath
    private var selectedIndexPath: IndexPath?
    
    private lazy var deleteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage.imageNamed(for: "delete_navi"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(didClickedDeleteButton(_:)), for: .touchUpInside)
        return btn
    }()

    private lazy var settingButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "gearshape"), for: .normal)
        btn.tintColor = .theme.label
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(didTapSettingButton), for: .touchUpInside)
        return btn
    }()
    
    // 添加手势识别器属性
    private lazy var longPressGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        return gesture
    }()
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard let previousTraitCollection = previousTraitCollection else { return }
        if (previousTraitCollection.hasDifferentColorAppearance(comparedTo: traitCollection)) {
            setupViewBackground()
        }
    }
    
    override func setupUI() {
        super.setupUI()

        setupViewBackground()
        
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0.0
        }
        tableView.estimatedSectionFooterHeight = 0
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.register(cellWithClass: HistoryCell.self)
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.addGestureRecognizer(longPressGesture)
        
//        addRefresh()
        addEmpty()
        setupNavigationItem()
    }
    
    override func setupData() {
        super.setupData()
        bindViewModel()
        reloadData()
    }
    
    func reloadData() {
        tableView.startLoading()
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            await self?.viewModel.reloadData()
        }
    }
    
    deinit {
        loadTask?.cancel()
        deleteTask?.cancel()
    }
}

private extension HistoryViewController {
    func bindViewModel() {
        viewModel.onDataLoaded = { [weak self] _ in
            guard let self else { return }
            self.tableView.endLoading()
            self.tableView.reloadData()
            self.displayEmpty(.empty)
        }
        
        viewModel.onDataLoadFailed = { [weak self] message in
            guard let self else { return }
            self.tableView.endLoading()
            ProgressHUD.showError(withStatus: message)
            self.displayEmpty(.error)
        }
    }
    
    private func setupViewBackground() {
        if traitCollection.userInterfaceStyle == .dark {
            view.layer.contents = nil
            setupBackground()
        } else {
            view.layer.contents = UIImage.imageNamed(for: "background_list")?.cgImage
        }
    }
    
    /// 添加刷新
//    private func addRefresh() {
//        tableView.mj_header = AppRefreshHeader(refreshingTarget: self,
//                                                    refreshingAction: #selector(getNewData))
//        tableView.mj_footer = AppRefreshFooter(refreshingTarget: self,
//                                                    refreshingAction: #selector(getMoreData))
//    }
    
    private func addEmpty() {
        let empty = EmptyView()
        empty.retryCallback = { [weak self] sender in
            self?.tableView.hideEmpty()
//            self?.tableView.mj_header?.beginRefreshing()
        }
        tableView.emptyView = empty
    }

    func displayEmpty(_ state: EmptyViewState) {
        guard viewModel.sections.isEmpty else {
            self.tableView.hideEmpty()
//            self.deleteButton.isHidden = false
            return
        }
        self.tableView.showState(state)
//        self.deleteButton.isHidden = true
    }
    
    private func setupNavigationItem() {
        if #available(iOS 26.0, *) {
            navigationItem.largeTitle = NSLocalizedString("历史会话", bundle: .module, comment: "")
            navigationItem.largeTitleDisplayMode = .inline
        } else {
            navigationItem.title = NSLocalizedString("历史会话", bundle: .module, comment: "")
            navigationItem.largeTitleDisplayMode = .always
        }

        let settingItem = UIBarButtonItem(customView: settingButton)
        navigationItem.rightBarButtonItem = settingItem
        
//        let deleteItem = UIBarButtonItem(customView: deleteButton)
//        navigationItem.rightBarButtonItem = deleteItem
//        deleteButton.isHidden = true
    }
}

private extension HistoryViewController {
    @objc func didTapSettingButton() {
        Router.present(from: self, to: SettingProtocol.self, animated: true)
    }

    @objc private func handleLongPress(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            // 只在手势开始时检查是否长按在 cell 上
            let point = gesture.location(in: tableView)
            guard let indexPath = tableView.indexPathForRow(at: point),
                  let cell = tableView.cellForRow(at: indexPath) as? HistoryCell else {
                return
            }
            
            selectedIndexPath = indexPath
            
            MenuViewController.shared.show(
                from: cell.bubbleView,
                in: self,
                items: [
                    MenuItem(title: NSLocalizedString("删除", bundle: .module, comment: ""),
                            image: UIImage.imageNamed(for: "delete_menu"))
                ]
            ) { [weak self] index in
                self?.deleteHistory()
            }
            
        case .ended, .cancelled:
            // 可选：在手势结束时处理一些清理工作
            break
            
        default:
            break
        }
    }
}

private extension HistoryViewController {
    @objc func didClickedDeleteButton(_ sender: UIButton) {
        let title = NSLocalizedString("清除会话确认", bundle: .module, comment: "")
        let message = NSLocalizedString("确定要清空所有历史会话吗？一旦删除将无法恢复！", bundle: .module, comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = .theme.label
        alert.addAction(UIAlertAction(title: NSLocalizedString("取消", bundle: .module, comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("确定", bundle: .module, comment: ""), style: .destructive, handler: { [weak self] _ in
            self?.deleteAllHistory()
        }))
        if let popover = popoverPresentationController {
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
        }
        present(alert, animated: true, completion: nil)
    }

    func deleteAllHistory() {
        deleteTask?.cancel()
        deleteTask = Task { [weak self] in
            guard let self else { return }
            
            do {
                try await viewModel.deleteAllHistory()
                tableView.reloadData()
                displayEmpty(.empty)
                NotificationCenter.default.post(name: .historyDidDeleteAll, object: nil)
            } catch is CancellationError {
                return
            } catch {
                ProgressHUD.showError(withStatus: "删除失败")
            }
        }
    }

    @objc private func deleteHistory() {
        guard let indexPath = selectedIndexPath else { return }
        
        let history = viewModel.record(at: indexPath)
        print("删除会话: \(history.detailList?.first?.content ?? "")")

        tableView.isUserInteractionEnabled = false
        tableView.startLoading()

        deleteTask?.cancel()
        deleteTask = Task { [weak self] in
            guard let self else { return }
            
            defer {
                tableView.endLoading()
                tableView.isUserInteractionEnabled = true
            }
            
            do {
                let historyId = try await viewModel.deleteHistory(at: indexPath)
                
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                if indexPath.section >= viewModel.numberOfSections() ||
                    indexPath.row >= viewModel.numberOfRows(in: indexPath.section) {
                    tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
                }
                
                displayEmpty(.empty)
                NotificationCenter.default.post(name: .historyDidDeleteChat, object: historyId)
            } catch is CancellationError {
                return
            } catch {
                ProgressHUD.showError(withStatus: "删除失败")
            }
        }
    }
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: HistoryCell.self)
        cell.configure(with: viewModel.item(at: indexPath))
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleForHeader(in: section)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1// CGFLOAT_MIN
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = viewModel.record(at: indexPath)
        // 处理单元格选择,例如打开会话详情页面
        print("选择了会话: \(model.updateTime ?? "")")
        
        // 直接换数据
        if let closure = openHistoryClosure {
            closure(model.id)
            return
        }
        
        // 打开新页面
        let vc = AIChatViewController()
        vc.historyId = model.id
        vc.hidesBottomBarWhenPushed = true
        guard var viewControllers = navigationController?.viewControllers else { return }
        var chatIndex: Int?
        for (index, viewController) in viewControllers.enumerated() {
            if viewController is AIChatViewController {
                chatIndex = index
                break
            }
        }
        if let index = chatIndex { // 移除聊天页面
            viewControllers.remove(at: index)
            viewControllers.insert(vc, at: index)
            navigationController?.setViewControllers(viewControllers, animated: false)
            navigationController?.popViewController(animated: true)
        } else {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension HistoryViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
}
