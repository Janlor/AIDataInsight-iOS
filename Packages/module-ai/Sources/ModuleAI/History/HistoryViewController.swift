//
//  HistoryViewController.swift
//  ModuleAI
//
//  Created by Janlor on 2024/10/24.
//

import UIKit
import BaseUI
import Networking
import SwifterSwift

extension Notification.Name {
    static let historyDidDeleteAll = Notification.Name("AI.HistoryDidDeleteAllNotification")
    static let historyDidDeleteChat = Notification.Name("AI.HistoryDidDeleteChatNotification")
}

class HistoryViewController: BaseViewController {
    private var tableView: UITableView!
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    /// 分页每页数量
    private let pageSize: Int = 50
    /// 添加属性保存当前长按的 indexPath
    private var selectedIndexPath: IndexPath?
    /// 数据源
    private var pageModel: RecordPageModel?
    private var dataSourse: [[RecordModel]] = []
    
    private lazy var deleteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage.imageNamed(for: "delete_navi"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(didClickedDeleteButton(_:)), for: .touchUpInside)
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
        self.tableView.startLoading()
        getNewData()
    }
}

private extension HistoryViewController {
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
        guard dataSourse.isEmpty else {
            self.tableView.hideEmpty()
//            self.deleteButton.isHidden = false
            return
        }
        self.tableView.showState(state)
//        self.deleteButton.isHidden = true
    }
    
    private func setupNavigationItem() {
        title = NSLocalizedString("历史会话", bundle: .module, comment: "")
        
//        let deleteItem = UIBarButtonItem(customView: deleteButton)
//        navigationItem.rightBarButtonItem = deleteItem
//        deleteButton.isHidden = true
    }
}

private extension HistoryViewController {
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
        deleteAllHistory { [weak self] result in
            guard let `self` = self else { return }
            guard result == true else {
                ProgressHUD.showError(withStatus: "删除失败")
                return
            }
            self.dataSourse = []
            self.tableView.reloadData()
            self.displayEmpty(.empty)
            NotificationCenter.default.post(name: .historyDidDeleteAll, object: nil)
        }
    }

    @objc private func deleteHistory() {
        guard let indexPath = selectedIndexPath else { return }
        
        let history = dataSourse[indexPath.section][indexPath.row]
        print("删除会话: \(history.detailList?.first?.content ?? "")")

        tableView.isUserInteractionEnabled = false
        tableView.startLoading()

        deleteHistory(historyId: history.id) { [weak self] result in
            guard let `self` = self else { return }
            self.tableView.endLoading()
            self.tableView.isUserInteractionEnabled = true
            guard result == true else {
                ProgressHUD.showError(withStatus: "删除失败")
                return
            }
            
            // 从数据源删除
            self.dataSourse[indexPath.section].remove(at: indexPath.row)
            
            // 从界面删除
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            
            // 如果该分组没有数据了，删除整个分组
            if self.dataSourse[indexPath.section].isEmpty {
                self.dataSourse.remove(at: indexPath.section)
                self.tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
            }
            
            self.displayEmpty(.empty)
            NotificationCenter.default.post(name: .historyDidDeleteChat, object: history.id)
        }
    }
}

// MARK: - Network

private extension HistoryViewController {
    /// 获取新数据
    @objc func getNewData() {
        getDataList(pageNo: 1, pageSize: pageSize)
    }
    
    /// 获取更多数据
    @objc func getMoreData() {
        let current = (pageModel?.currentPage ?? 0) + 1
        getDataList(pageNo: current, pageSize: pageSize)
    }
    
    /// 分页获取数据
    /// - Parameters:
    ///   - pageNo: 页码
    ///   - pageSize: 每页数量
    func getDataList(pageNo: Int, pageSize: Int) {
        let target = HistoryApi.page(pageNo, pageSize)
        ResponseModel<RecordPageModel>.requestable(target) {
            [weak self] response, error in
            guard let `self` = self else { return }
            self.tableView.endLoading()
//            self.tableView.mj_header?.endRefreshing()
//            self.tableView.mj_footer?.endRefreshing()
            
            // 处理���误
            guard error == nil,
                  let model = response?.data else {
                ProgressHUD.showError(withStatus: response?.msg)
                self.displayEmpty(.error)
                return
            }
            
            // 是否有更多数据
//            if model.currentPage ?? 0 < model.pages ?? 0 {
//                self.tableView.mj_footer?.resetNoMoreData()
//            } else {
//                self.tableView.mj_footer?.endRefreshingWithNoMoreData()
//            }

            // 修改数据源
            self.pageModel = model
            
            // 修改数据源
            DispatchQueue.global().async {
                let groupedNewRecords = RecordModel.groupRecordsByDate(records: model.records, dateFormatter: self.dateFormatter)
                if model.currentPage ?? 1 == 1 || self.dataSourse.isEmpty {
                    self.dataSourse = groupedNewRecords
                } else {
                    // 将新记录添加到现有分组中
                    RecordModel.mergeGroupedRecords(existing: &self.dataSourse, new: groupedNewRecords, dateFormatter: self.dateFormatter)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.displayEmpty(.empty)
                }
            }
        }
    }

    func deleteHistory(historyId: Int?, completion: @escaping (Bool?) -> Void) {
        guard let id = historyId else { return }
        let target = HistoryApi.delete(id)
        ResponseModel<EmptyModel>.requestable(target) { response, error in
            let result = error == nil && response?.code == 200
            completion(result)
        }
    }

    func deleteAllHistory(completion: @escaping (Bool?) -> Void) {
        let target = HistoryApi.deleteAll
        ResponseModel<EmptyModel>.requestable(target) { response, error in
            let result = error == nil && response?.code == 200
            completion(result)
        }
    }
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSourse.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourse[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: HistoryCell.self)
        let model = dataSourse[indexPath.section][indexPath.row]
        cell.configure(with: model)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let firstRecord = dataSourse[section].first else { return nil }
        guard let date = dateFormatter.date(from: firstRecord.updateTime ?? "") else { return nil }
        let calendar = Calendar.current
        return RecordModel.groupKeyForDate(date, calendar: calendar).0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1// CGFLOAT_MIN
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = dataSourse[indexPath.section][indexPath.row]
        // 处理单元格选择,例如打开会话详情页面
        print("选择了会话: \(model.updateTime ?? "")")
        
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
