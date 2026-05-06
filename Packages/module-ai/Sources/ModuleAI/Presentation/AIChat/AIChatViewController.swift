//
//  AIChatViewController.swift
//  ModuleAI
//
//  Created by Janlor on 2024/10/23.
//

import UIKit
import BaseKit
import BaseUI
import SwifterSwift

class AIChatViewController: BaseViewController {
    /// 打开更多菜单
    var didClickedMoreMenu: ((UIBarButtonItem) -> Void)?
    /// 历史会话ID
    public var historyId: Int?
    
    enum Section {
        case main
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, AIChat>!
    private var collectionView: UICollectionView!
    
    private let chatBottomView = AIChatBottomView()
    private var chatBottomConstraint: NSLayoutConstraint!
    
    /// 数据源
    private let viewModel = AIChatViewModel()
    private var loadTask: Task<Void, Never>?
    private var sendTask: Task<Void, Never>?
    private var feedbackTask: Task<Void, Never>?
    
    /// AI 是否思考中 思考中不能发送消息
    private var isAIThinking = false {
        didSet {
            chatBottomView.isEnabled = !isAIThinking
        }
    }
    
    private var lastAIChat: AIChat?
    private var streamDisplayLink: CADisplayLink?
    private var pendingStreamText = ""
    private var renderedStreamText = ""
    private var didReceiveStreamCompletion = false
    private let streamCharactersPerFrame = 1
    
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
        
        bindViewModel()
        
        if let historyId = historyId {
            loadTask?.cancel()
            loadTask = Task { [weak self] in
                await self?.viewModel.getHistoryDetail(historyId)
            }
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            loadTask?.cancel()
            loadTask = Task { [weak self] in
                await self?.viewModel.loadTemplate()
            }
        }
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
        loadTask?.cancel()
        sendTask?.cancel()
        feedbackTask?.cancel()
        stopStreamDisplayLink()
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

private extension AIChatViewController {
     func bindViewModel() {
        
         viewModel.onHistoryLoaded = { [weak self] chats in
             self?.showHistoryMessages(chats)
         }
         
         viewModel.onTemplateLoaded = { [weak self] questions in
             self?.showWelcomeMessage(questions)
         }
        
        viewModel.onFunctionResult = { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .timeout:
                self.showTimeOutMessage()
                
            case .error(let msg):
                self.showErrorMessage(msg: msg)
                
            case .intent(let text, let type):
                self.showIntentMessage(text: text, intentType: type)
            }
        }
        
        viewModel.onChartResult = { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .timeout:
                self.showTimeOutMessage()
                
            case .error(let msg):
                self.showErrorMessage(msg: msg)
                
            case .success(let funcType, let historyDetailId, let datas):
                self.showChartMessage(funcType: funcType, historyDetailId: historyDetailId, chartDatas: datas)
            }
        }
        
        viewModel.onStreamText = { [weak self] chunk in
            self?.appendStreamChunk(chunk)
        }
        
        viewModel.onStreamCompleted = { [weak self] in
            self?.finishStreamResponse()
        }
        
        viewModel.onStreamFailed = { [weak self] message in
            self?.showErrorMessage(msg: message)
        }
    }
    
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
        resetStreamingState()
        lastAIChat = AIChat(text: "智能引擎全力运转，您的答案即将揭晓。", type: .ai)
        
        var snapshot = dataSource.snapshot()
        snapshot.appendItems([userAIChat, lastAIChat!], toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
        scrollToBottomItem(snapshot)
        isAIThinking = true
        startStreamDisplayLink()
        
        /// 函数调用分析
        sendTask?.cancel()
        sendTask = Task { [weak self] in
            await self?.viewModel.sendFunctionMessage(text)
        }
    }
    
    func sendUserStreamMessage(_ text: String) {
//        chatBottomView.isClearEnabled = true
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        guard !isAIThinking else {
            return
        }
        
        // 处理发送消息的逻辑
        print("发送消息: \(text)")
        
        let userAIChat = AIChat(text: text, type: .user)
        resetStreamingState()
        lastAIChat = AIChat(text: "", type: .ai)
        
        var snapshot = dataSource.snapshot()
        snapshot.appendItems([userAIChat, lastAIChat!], toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
        scrollToBottomItem(snapshot)
        isAIThinking = true
        startStreamDisplayLink()
        
        viewModel.sendStreamMessage(text)
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
        resetStreamingState()
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
        resetStreamingState()
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
        resetStreamingState()
        guard let aiAIChat = lastAIChat else { return }
        var snapshot = self.dataSource.snapshot()
        snapshot.deleteItems([aiAIChat])
        self.lastAIChat = AIChat(text: text, type: .intent, intentType: intentType)
        snapshot.appendItems([self.lastAIChat!], toSection: .main)
        self.dataSource.apply(snapshot, animatingDifferences: true)
        self.scrollToBottomItem(snapshot)
    }
    
    func showChartMessage(funcType: FunctionName?, historyDetailId: Int?, chartDatas: [AIBarChartData]) {
        resetStreamingState()
        guard let aiAIChat = lastAIChat else { return }
        var snapshot = self.dataSource.snapshot()
        snapshot.deleteItems([aiAIChat])
        self.lastAIChat = AIChat(text: "根据您的查询，以下是分析结果:", type: .chart, barChartDatas: chartDatas, historyDetailId: historyDetailId, funcType: funcType)
        snapshot.appendItems([self.lastAIChat!], toSection: .main)
        self.dataSource.apply(snapshot, animatingDifferences: true)
        self.scrollToBottomItem(snapshot)
        self.isAIThinking = false
    }
    
    func removeLastAIChat() {
        resetStreamingState()
        guard let lastAIChat = lastAIChat else { return }
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([lastAIChat])
        dataSource.apply(snapshot, animatingDifferences: true)
        isAIThinking = false
    }
    
    func clearChat() {
        loadTask?.cancel()
        sendTask?.cancel()
        feedbackTask?.cancel()
        viewModel.resetConversation()
        resetStreamingState()
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
    
    func appendStreamChunk(_ chunk: String) {
        pendingStreamText += chunk
    }
    
    func finishStreamResponse() {
        didReceiveStreamCompletion = true
        finalizeStreamIfNeeded()
    }
    
    func startStreamDisplayLink() {
        stopStreamDisplayLink()
        
        let displayLink = CADisplayLink(target: self, selector: #selector(handleStreamDisplayLink))
        if #available(iOS 15.0, *) {
            displayLink.preferredFrameRateRange = CAFrameRateRange(minimum: 8, maximum: 12, preferred: 10)
        } else {
            displayLink.preferredFramesPerSecond = 10
        }
        displayLink.add(to: .main, forMode: .common)
        streamDisplayLink = displayLink
    }
    
    func stopStreamDisplayLink() {
        streamDisplayLink?.invalidate()
        streamDisplayLink = nil
    }
    
    func resetStreamingState() {
        stopStreamDisplayLink()
        pendingStreamText = ""
        renderedStreamText = ""
        didReceiveStreamCompletion = false
    }
    
    @objc func handleStreamDisplayLink() {
        updateStreamingAIMessageIfNeeded()
    }
    
    func updateStreamingAIMessageIfNeeded() {
        guard renderedStreamText != pendingStreamText else { return }
        
        let nextText = nextRenderedText()
        guard nextText != renderedStreamText else { return }
        renderedStreamText = nextText
        
        guard var aiChat = lastAIChat else { return }
        aiChat.text = renderedStreamText
        lastAIChat = aiChat
        
        guard let itemIndex = dataSource.snapshot().indexOfItem(aiChat) else { return }
        let indexPath = IndexPath(item: itemIndex, section: 0)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? AIChatCell {
            cell.configure(with: aiChat.text)
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            UIView.performWithoutAnimation {
                collectionView.collectionViewLayout.invalidateLayout()
                collectionView.layoutIfNeeded()
                collectionView.scrollToBottom(animated: false)
            }
        }
        
        finalizeStreamIfNeeded()
    }
    
    func nextRenderedText() -> String {
        guard renderedStreamText.count < pendingStreamText.count else {
            return renderedStreamText
        }
        
        let startIndex = pendingStreamText.index(
            pendingStreamText.startIndex,
            offsetBy: renderedStreamText.count
        )
        var currentIndex = startIndex
        var consumedCharacters = 0
        
        while currentIndex < pendingStreamText.endIndex, consumedCharacters < streamCharactersPerFrame {
            let character = pendingStreamText[currentIndex]
            
            if character.isASCIIWordCharacter {
                while currentIndex < pendingStreamText.endIndex,
                      pendingStreamText[currentIndex].isASCIIWordCharacter {
                    currentIndex = pendingStreamText.index(after: currentIndex)
                }
                
                while currentIndex < pendingStreamText.endIndex,
                      pendingStreamText[currentIndex].isWhitespace {
                    currentIndex = pendingStreamText.index(after: currentIndex)
                }
            } else {
                currentIndex = pendingStreamText.index(after: currentIndex)
            }
            
            consumedCharacters += 1
        }
        
        return String(pendingStreamText[..<currentIndex])
    }
    
    func finalizeStreamIfNeeded() {
        guard didReceiveStreamCompletion, renderedStreamText == pendingStreamText else { return }
        stopStreamDisplayLink()
        
        guard var aiChat = lastAIChat else {
            isAIThinking = false
            return
        }
        
        if aiChat.text.isEmpty {
            aiChat.text = "暂未获取到回复内容，请稍后重试。"
            lastAIChat = aiChat
        }
        
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([aiChat])
        snapshot.appendItems([aiChat], toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false)
        scrollToBottomItem(snapshot, animated: false)
        isAIThinking = false
    }
}

private extension Character {
    var isASCIIWordCharacter: Bool {
        unicodeScalars.allSatisfy { scalar in
            scalar.isASCII && (CharacterSet.alphanumerics.contains(scalar) || scalar == "_")
        }
    }
}

extension AIChatViewController: AIChatBottomViewDelegate {
    func chatBottomView(_ chatBottomView: AIChatBottomView, didClickedClear sender: UIButton) {
        clearChat()
        setupData()
    }
    
    func chatBottomView(_ chatBottomView: AIChatBottomView, didTapSendWithText text: String) {
        sendUserStreamMessage(text)
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
        feedbackTask?.cancel()
        feedbackTask = Task { [weak self, weak sender] in
            guard let self, let sender else { return }
            let result = await viewModel.sendLikeFeedback(historyDetailId: historyDetailId, like: like)
            sender.isUserInteractionEnabled = true
            guard result else {
                ProgressHUD.showError(withStatus: "操作失败")
                sender.isSelected = false
                return
            }
            sender.isSelected = true
        }
    }
}
