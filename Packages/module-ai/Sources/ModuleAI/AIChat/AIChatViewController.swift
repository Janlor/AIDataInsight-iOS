//
//  AIChatViewController.swift
//  ModuleAI
//
//  Created by Janlor on 2024/10/23.
//

import UIKit
import BaseKit
import BaseUI
import Networking
import SwifterSwift
//import IQKeyboardManagerSwift

class AIChatViewController: BaseViewController {
    /// 打开更多菜单
    var didClickedMoreMenu: ((UIBarButtonItem) -> Void)?
    
    public var historyId: Int?
    
    enum Section {
        case main
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, AIChat>!
    private var collectionView: UICollectionView!
    
    private let chatBottomView = AIChatBottomView()
    private var chatBottomConstraint: NSLayoutConstraint!
    
    /// AI 是否思考中 思考中不能发送消息
    var isAIThinking = false {
        didSet {
            chatBottomView.isEnabled = !isAIThinking
        }
    }
    
    var lastAIChat: AIChat?
    
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
        setupCollectionView()
        setupChatBottomView()
        setupNavigationItem()
        configureDataSource()
        addNotifications()
    }
    
    override func setupData() {
        super.setupData()
        
        if let historyId = historyId {
            getHistoryDetail(historyId)
        } else {
            getTemplate()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        IQKeyboardManager.shared.isEnabled = false
    }
    
    func isInputing() -> Bool {
        chatBottomView.isFirstResponder
    }
    
    func focusInput() {
        chatBottomView.becomeFirstResponder()
    }
    
    func loadConversation(_ id: Int?) {
        clearChat()
        historyId = id
        setupData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension AIChatViewController {
    private func setupViewBackground() {
        if traitCollection.userInterfaceStyle == .dark {
            view.layer.contents = nil
            setupBackground()
        } else {
            view.layer.contents = UIImage.imageNamed(for: "background_vc")?.cgImage
        }
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.keyboardDismissMode = .onDrag
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapedCollectionView(_:)))
        collectionView.addGestureRecognizer(tap)
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        if #available(iOS 15.0, *) {
            collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        } else {
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        }
        
        collectionView.register(cellWithClass: AIChatWelcomeCell.self)
        collectionView.register(cellWithClass: AIChatCell.self)
        collectionView.register(cellWithClass: AIChatUserCell.self)
        collectionView.register(cellWithClass: AIChatIntentCell.self)
        collectionView.register(cellWithClass: AIChatChartCell.self)
        collectionView.register(cellWithClass: AIChatLegendChartCell.self)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(44))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, AIChat>(collectionView: collectionView) {
            [weak self] (collectionView, indexPath, chat) -> UICollectionViewCell? in
            if chat.type == .welcome {
                let cell = collectionView.dequeueReusableCell(withClass: AIChatWelcomeCell.self, for: indexPath)
                cell.delegate = self
                cell.questions = chat.questions
                return cell
            }
            
            if chat.type == .user {
                let cell = collectionView.dequeueReusableCell(withClass: AIChatUserCell.self, for: indexPath)
                cell.configure(with: chat.text)
                return cell
            }
            
            if chat.type == .intent {
                let cell = collectionView.dequeueReusableCell(withClass: AIChatIntentCell.self, for: indexPath)
                cell.delegate = self
                cell.chatModel = chat
                return cell
            }
            
            if chat.type == .chart {
                if let datas = chat.barChartDatas, let values = datas.first?.values, values.count > 1 {
                    let cell = collectionView.dequeueReusableCell(withClass: AIChatLegendChartCell.self, for: indexPath)
                    cell.delegate = self
                    cell.chatModel = chat
                    return cell
                }
                let cell = collectionView.dequeueReusableCell(withClass: AIChatChartCell.self, for: indexPath)
                cell.delegate = self
                cell.chatModel = chat
                return cell
            }
            
            let cell = collectionView.dequeueReusableCell(withClass: AIChatCell.self, for: indexPath)
            cell.configure(with: chat.text)
            return cell
        }
        
        // 初始化空的数据源
        var snapshot = NSDiffableDataSourceSnapshot<Section, AIChat>()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    @objc func didTapedCollectionView(_ sender: UICollectionView) {
        let _ = chatBottomView.resignFirstResponder()
    }
    
    func scrollToBottomItem(_ snapshot: NSDiffableDataSourceSnapshot<Section, AIChat>? = nil, animated: Bool = true) {
        guard !collectionView.isDragging else { return }
        let snapshot = snapshot ?? dataSource.snapshot()
        collectionView.scrollToItem(at: IndexPath(item: snapshot.numberOfItems - 1, section: 0), at: .bottom, animated: animated)
    }
}

extension AIChatViewController {
    func setupNavigationItem() {
        navigationItem.title = NSLocalizedString("AI数据分析助手", bundle: .module, comment: "")
        
        let rightButton = UIBarButtonItem(image: UIImage(systemName: "bubble.and.pencil"), style: .plain, target: self, action: #selector(didClickedNewChat))
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let leftButton = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease"), style: .plain, target: self, action: #selector(didClickedMoreMenuItem))
        navigationItem.leftBarButtonItem = leftButton
    }
    
    @objc func didClickedNewChat(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        clearChat()
        setupData()
    }
    
    @objc func didClickedMoreMenuItem(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        didClickedMoreMenu?(sender)
    }
}

extension AIChatViewController {
    private func setupChatBottomView() {
        view.addSubview(chatBottomView)
        chatBottomView.translatesAutoresizingMaskIntoConstraints = false
        chatBottomView.delegate = self
        chatBottomConstraint = chatBottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.mSpacing)
        chatBottomConstraint.priority = .required - 1
        
        NSLayoutConstraint.activate([
            chatBottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatBottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatBottomConstraint,
            chatBottomView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: chatBottomView.topAnchor)
        ])
    }
}

extension AIChatViewController {
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(historyDidDeleteAll), name: .historyDidDeleteAll, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(historyDidDeleteChat(_:)), name: .historyDidDeleteChat, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notify: Notification) {
        guard chatBottomConstraint.constant >= -view.mSpacing else {
            return
        }
        
        let duration: TimeInterval = notify.userInfo?[UIApplication.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        let curve = notify.userInfo?[UIApplication.keyboardAnimationCurveUserInfoKey] as? UInt ?? 0
        let rect = notify.userInfo?[UIApplication.keyboardFrameEndUserInfoKey] as? CGRect
        let keyboardH = rect?.height ?? 366
        let bottom = keyboardH + 8
        let options = UIView.AnimationOptions(rawValue: curve)
        
        chatBottomConstraint.constant = -bottom
        UIView.animate(withDuration: duration, delay: 0, options: options) {
            self.view.layoutIfNeeded()
            self.collectionView.scrollToBottom(animated: false)
        }
    }
    
    @objc private func keyboardWillHide(_ notify: Notification) {
        guard chatBottomConstraint.constant < -view.mSpacing else {
            return
        }
        
        let duration: TimeInterval = notify.userInfo?[UIApplication.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        let curve = notify.userInfo?[UIApplication.keyboardAnimationCurveUserInfoKey] as? UInt ?? 0
        let options = UIView.AnimationOptions(rawValue: curve)
        
        chatBottomConstraint.constant = -view.mSpacing
        UIView.animate(withDuration: duration, delay: 0, options: options) {
            self.view.layoutIfNeeded()
            self.collectionView.scrollToBottom(animated: false)
        }
    }
    
    @objc private func historyDidDeleteAll(_ notify: Notification) {
        clearChat()
        setupData()
    }
    
    @objc private func historyDidDeleteChat(_ notify: Notification) {
        guard let id = notify.object as? Int else { return }
        guard id == historyId else { return }
        clearChat()
        setupData()
    }
}

extension AIChatViewController {
    func showHistoryMessages(_ chats: [AIChat]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(chats, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
        scrollToBottomItem(snapshot, animated: false)
    }
    
    func showWelcomeMessage(_ questions: [String]?) {
        guard let questions = questions else { return }
        let welcome = AIChat(text: "", type: .welcome, questions: questions)
        var snapshot = dataSource.snapshot()
        snapshot.appendItems([welcome], toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func sendUserMessage(_ text: String) {
//        chatBottomView.isClearEnabled = true
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        guard !isAIThinking else {
            return
        }
        
        // 处理发送消息的逻辑
        print("发送消息: \(text)")
        
        let userAIChat = AIChat(text: text, type: .user)
        lastAIChat = AIChat(text: "智能引擎全力运转，您的答案即将揭晓。", type: .ai)
        
        var snapshot = dataSource.snapshot()
        snapshot.appendItems([userAIChat, lastAIChat!], toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
        scrollToBottomItem(snapshot)
        isAIThinking = true
        
        /// 函数调用分析
        sendFunctionMessage(text)
    }
    
    func showThinkingMessage() {
        var snapshot = dataSource.snapshot()
        if let lastAIChat = lastAIChat {
            snapshot.deleteItems([lastAIChat])
        }
        lastAIChat = AIChat(text: "智能引擎全力运转，您的答案即将揭晓。", type: .ai)
        snapshot.appendItems([lastAIChat!], toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
        scrollToBottomItem(snapshot)
    }
    
    func showTimeOutMessage() {
        guard let aiAIChat = lastAIChat else { return }
        var snapshot = self.dataSource.snapshot()
        snapshot.deleteItems([aiAIChat])
        let text = "非常抱歉，回答您的问题超出了预期时间。可能是由于系统繁忙。请稍后再试或重新提问。"
        let errorChat = AIChat(text: text, type: .ai)
        snapshot.appendItems([errorChat], toSection: .main)
        self.dataSource.apply(snapshot, animatingDifferences: true)
        self.scrollToBottomItem(snapshot)
        self.isAIThinking = false
    }
    
    func showErrorMessage(msg: String?) {
        guard let aiAIChat = lastAIChat else { return }
        var snapshot = self.dataSource.snapshot()
        snapshot.deleteItems([aiAIChat])
        let text = msg ?? "这个问题目前无法回答。请尝试以不同的方式重新表述您的问题。"
        let errorChat = AIChat(text: text, type: .ai)
        snapshot.appendItems([errorChat], toSection: .main)
        self.dataSource.apply(snapshot, animatingDifferences: true)
        self.scrollToBottomItem(snapshot)
        self.isAIThinking = false
    }
    
    func showIntentMessage(text: String, intentType: AIChatIntentType) {
        guard let aiAIChat = lastAIChat else { return }
        var snapshot = self.dataSource.snapshot()
        snapshot.deleteItems([aiAIChat])
        self.lastAIChat = AIChat(text: text, type: .intent, intentType: intentType)
        snapshot.appendItems([self.lastAIChat!], toSection: .main)
        self.dataSource.apply(snapshot, animatingDifferences: true)
        self.scrollToBottomItem(snapshot)
    }
    
    func showChartMessage(model: HistoryDetailModel, chartDatas: [AIBarChartData]) {
        guard let aiAIChat = lastAIChat else { return }
        var snapshot = self.dataSource.snapshot()
        snapshot.deleteItems([aiAIChat])
        self.lastAIChat = AIChat(text: "根据您的查询，以下是分析结果:", type: .chart, barChartDatas: chartDatas, historyDetailId: model.historyDetailId, funcType: model.funcType)
        snapshot.appendItems([self.lastAIChat!], toSection: .main)
        self.dataSource.apply(snapshot, animatingDifferences: true)
        self.scrollToBottomItem(snapshot)
        self.isAIThinking = false
    }
    
    func removeLastAIChat() {
        guard let lastAIChat = lastAIChat else { return }
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([lastAIChat])
        dataSource.apply(snapshot, animatingDifferences: true)
        isAIThinking = false
    }
}

private extension AIChatViewController {
    func getHistoryDetail(_ historyId: Int) {
        let target = HistoryApi.detail(historyId)
        ResponseModel<RecordModel>.requestable(target) {
            [weak self] response, error in
            guard let `self` = self else { return }
            guard error == nil,
                  let model = response?.data,
                  let detailList = model.detailList else {
                return
            }
            DispatchQueue.global().async {
                let detailList = DetailModel.decodeDetailList(detailList)
                let chats = detailList.map {
                    var isLike: Bool?
                    if let like = $0.isLike {
                        isLike = like == "1"
                    }
                    if $0.type == .question {
                        return AIChat(text: $0.content ?? "", type: .user)
                    }
                    if let chatModel = $0.chatModel {
                        let result = self.generateBarChartDatas(chatModel)
                        if let datas = result.0 {
                            return AIChat(text: "根据您的查询，以下是分析结果:", type: .chart, isLike: isLike, barChartDatas: datas, historyDetailId: $0.id, funcType: chatModel.funcType)
                        }
                        return AIChat(text: result.1 ?? "数据分析还在测试阶段，很快就能上线，敬请期待！", type: .ai)
                    }
                    if let funcModel = $0.funcModel {
                        return AIChat(text: funcModel.msg ?? "", type: .ai)
                    }
                    return AIChat(text: $0.content ?? "新版本上线啦，升级后我会变得更聪明，快来体验吧！", type: .ai)
                }
                DispatchQueue.main.async {
                    self.showHistoryMessages(chats)
                }
            }
        }
    }

    func getTemplate() {
        let target = ChatApi.template
        ResponseModel<String>.requestable(target) {
            [weak self] response, error in
            guard let `self` = self else { return }
            guard error == nil,
                  let string = response?.data else {
                return
            }
            guard let data = string.data(using: .utf8) else { return }
            let configure = try? appDecoder.decode(TemplateModel.self, from: data)
            self.showWelcomeMessage(configure?.questions)
        }
    }
    
    func sendFunctionMessage(_ text: String) {
        let target = ChatApi.function(text, historyId)
        ResponseModel<FunctionModel>.requestable(target) {
            [weak self] response, error in
            guard let `self` = self else { return }
            
            guard error == nil, let model = response?.data else {
                self.showTimeOutMessage()
                return
            }
            
            guard let historyId = model.historyId else {
                self.showErrorMessage(msg: model.msg)
                return
            }
            self.historyId = historyId
            
            guard let hasTool = model.hasTool, hasTool == true,
                  let name = model.name,
                  let arguments = model.arguments else {
                self.showErrorMessage(msg: model.msg)
                return
            }
            
            switch arguments {
            case let timeRange as TimeRangeQueryModel:
                if timeRange.startDate == nil {
                    self.showIntentMessage(text: text, intentType: .time)
                    return
                }
                
            case _ as PerformanceTypeQueryModel:
                self.showIntentMessage(text: text, intentType: .index)
                return
                
            default:
                break
            }
            
            self.getChartData(name: name, historyId: historyId, arguments: arguments)
        }
    }
    
    func getChartData(name: FunctionName, historyId: Int, arguments: Any) {
         guard let queryModel = arguments as? DictionaryConvertible else { return }
        let target = ChartApi.chart(name.rawValue, historyId, queryModel)
         ResponseModel<HistoryDetailModel>.requestable(target) {
             [weak self] response, error in
             guard let `self` = self else { return }
             guard error == nil else {
                 self.showTimeOutMessage()
                 return
             }
             guard let model = response?.data else {
                 self.showErrorMessage(msg: nil)
                 return
             }
             
             let result = self.generateBarChartDatas(model)
             guard let datas = result.0 else {
                 self.showErrorMessage(msg: result.1 ?? "数据分析还在测试阶段，很快就能上线，敬请期待！")
                 return
             }
             self.showChartMessage(model: model, chartDatas: datas)
        }
    }
    
    func generateBarChartDatas(_ model: HistoryDetailModel) -> ([AIBarChartData]?, String?) {
        if let chartCommonVoList = model.chartCommonVoList {
            let datas = chartCommonVoList.map { model in
                let title = model.name ?? ""
                let value = model.value ?? 0
                let color = AIBarChartData.colorOptions[0]
                return AIBarChartData(xAxis: title, colors: [color], labels: [title], values: [value])
            }
            return (datas, nil)
        }
        
        if let accountAgeGroupVoList = model.accountAgeGroupVoList {
            if let first = accountAgeGroupVoList.first,
               let chartType = first.chartType,
                chartType == "2",
               let msg = first.msg {
                return (nil, msg)
            }
            let datas = accountAgeGroupVoList.map { model in
                let name = model.name ?? ""
                let valueList = model.valueList ?? []
                let labelList = model.labelList ?? []
                var colors: [UIColor] = []
                for index in valueList.indices {
                    let i = index % (AIBarChartData.colorOptions.count)
                    colors.append(AIBarChartData.colorOptions[i])
                }
                return AIBarChartData(xAxis: name, colors: colors, labels: labelList, values: valueList)
            }
            return (datas, nil)
        }
        
        return (nil, nil)
    }
    
    func sendLikeFeedback(historyDetailId: Int, like: String, completion: @escaping (Bool?) -> Void) {
        let target = HistoryApi.like(historyDetailId, like)
        ResponseModel<EmptyModel>.requestable(target) { response, error in
            let result = error == nil && response?.code == 200
            completion(result)
        }
    }
    
    func clearChat() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: true)
        
        historyId = nil
        isAIThinking = false
        lastAIChat = nil
        navigationItem.rightBarButtonItem?.isEnabled = false
//        chatBottomView.isClearEnabled = false
    }
}

extension AIChatViewController: AIChatBottomViewDelegate {
    func chatBottomView(_ chatBottomView: AIChatBottomView, didClickedClear sender: UIButton) {
        clearChat()
        setupData()
    }
    
    func chatBottomView(_ chatBottomView: AIChatBottomView, didTapSendWithText text: String) {
        sendUserMessage(text)
    }
}

extension AIChatViewController: AIChatWelcomeCellDelegate {
    func chatWelcomeCell(_ cell: AIChatWelcomeCell, didTapText text: String) {
        sendUserMessage(text)
    }
}

extension AIChatViewController: AIChatIntentCellDelegate {
    func chatIntentCell(_ cell: AIChatIntentCell, didTapText text: String, chatModel: AIChat?) {
        showThinkingMessage()
        switch chatModel?.intentType {
        case .time:
            let fullText = text + (chatModel?.text ?? "")
            removeLastAIChat()
            sendUserMessage(fullText)
            return
        case .index:
            var fullText = (chatModel?.text ?? "")
            if !fullText.isLastCharacterPunctuation() {
                fullText += "，"
            }
            fullText += ("例如" + text)
            removeLastAIChat()
            sendUserMessage(fullText)
            return
        default:
            break
        }
    }
}

extension AIChatViewController: AIChatChartCellDelegate {
    func chatChartCell(_ cell: AIChatChartCell, didTapFeedback sender: UIButton, like: String, historyDetailId: Int?) {
        guard let historyDetailId = historyDetailId else { return }
        print("反馈: \(like)")
        sender.isUserInteractionEnabled = false
        sendLikeFeedback(historyDetailId: historyDetailId, like: like) { result in
            sender.isUserInteractionEnabled = true
            guard result == true else {
                ProgressHUD.showError(withStatus: "操作失败")
                sender.isSelected = false
                return
            }
            sender.isSelected = true
        }
    }
}
