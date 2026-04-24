//
//  NormalSearchBar.swift
//  LibraryCommon
//
//  Created by Janlor on 2024/5/31.
//

import UIKit
import BaseKit

public protocol NormalSearchBarDelegate: AnyObject {
//    func searchBarShouldBeginEditing(_ searchBar: NormalSearchBar) -> Bool // return NO to not become first responder
//    
//    func searchBarTextDidBeginEditing(_ searchBar: NormalSearchBar) // called when text starts editing
//    
//    func searchBarShouldEndEditing(_ searchBar: NormalSearchBar) -> Bool // return NO to not resign first responder
//    
//    func searchBarTextDidEndEditing(_ searchBar: NormalSearchBar) // called when text ends editing
    
//    func searchBar(_ searchBar: NormalSearchBar, textDidChange searchText: String) // called when text changes (including clear)
    
//    func searchBar(_ searchBar: NormalSearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool // called before text changes
    
    
//    func searchBarSearchButtonClicked(_ searchBar: NormalSearchBar) // called when keyboard search button pressed
    
//    func searchBarCancelButtonClicked(_ searchBar: NormalSearchBar) // called when cancel button pressed
}

public class NormalSearchBar: UIView, UITextFieldDelegate {
    
    public enum Style {
        case icon, button
    }
    
    /// 代理
//    public weak var delegate: NormalSearchBarDelegate?
    // 闭包
    public var didClickedSearch: ((String) -> Void)?
    // 闭包
    public var didClickedClear: ((String) -> Void)?
    // 闭包
    public var searchTextDidChanged: ((String) -> Void)?
    // 是否显示边框和阴影
    public var showBorderCornerShadow: Bool = true
    
    // 设置是否可用
    public var isEnabled: Bool = true {
        didSet {
            isUserInteractionEnabled = isEnabled
            if style == .button {
                searchButton.isEnabled = isEnabled
            }
        }
    }
    
    // MARK: - Properties
    
    private lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage.imageNamed(for: "BaseUI_search")?.withRenderingMode(.alwaysTemplate)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didClickedIconImageView(_:))))
        view.tintColor = .theme.tertieryLabel
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var searchButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(NSLocalizedString("搜索", bundle: .module, comment: ""), for: .normal)
        btn.titleLabel?.themeFont = .theme.title3
        btn.backgroundColor = .theme.accent
        btn.tintColor = .white
        btn.applyCapsule(.custom(13))
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.contentEdgeInsets = UIEdgeInsets(top: 4.5, left: 14, bottom: 4.5, right: 14)
        btn.addTarget(self, action: #selector(didClickedSearchButton(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var textField: UITextField = {
        let text = UITextField()
        text.textColor = UIColor.theme.label
        text.font = UIFont.theme.caption1
        text.clearButtonMode = .whileEditing
        text.returnKeyType = .search
        text.delegate = self
        text.translatesAutoresizingMaskIntoConstraints = false
        text.addTarget(self, action: #selector(textFieldDidChanged), for: .editingChanged)
        return text
    }()
    
    public var placeholder: String? {
        didSet {
            setPlaceholder(placeholder)
        }
    }
    
    public var defaultText: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
        }
    }
    
    public var searchText: String {
        return textField.text ?? ""
    }
    
    /// 样式 图标或按钮
    private var style: Style = .icon
    
    // MARK: - Initializers
    public init(style: Style) {
        super.init(frame: .zero)
        self.style = style
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if showBorderCornerShadow {
            appAddStyleView(borderWidth: 1, borderColor: .theme.separator, cornerRadius: bounds.height / 2, shadowColor: .black, shadowOpacity: 0.04, shadowOffset: .zero, shadowRadius: 4.0)
        }
    }
    
    // MARK: - Event
    
    public override var isFirstResponder: Bool {
        return textField.isFirstResponder
    }
    
    public override var canBecomeFirstResponder: Bool {
        return textField.canBecomeFirstResponder
    }
    
    public override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    @discardableResult
    public override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
    
    // MARK: - Private Methods
    private func setPlaceholder(_ placeholder: String?) {
        let placeholderText = placeholder?.isEmpty ?? true ? NSLocalizedString("搜索", bundle: .module, comment: "") : placeholder!
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.theme.caption1,
            .foregroundColor: UIColor.theme.quaternaryLabel
        ]
        textField.attributedPlaceholder = NSAttributedString.init(string: placeholderText, attributes: attributes)
    }
    
    private func setupUI() {
        if style == .icon {
            addSubview(iconImageView)
        } else {
            addSubview(searchButton)
        }
        addSubview(textField)
        setupConstraints()
    }
    
    private func setupConstraints() {
        let rightView = style == .icon ? iconImageView : searchButton
        let rightMargin: CGFloat = style == .icon ? 13 : 4
        
        NSLayoutConstraint.activate([
            rightView.centerYAnchor.constraint(equalTo: centerYAnchor),
            rightView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -rightMargin),
            
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.trailingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: -8)
        ])
        
        rightView.setContentHuggingPriority(.defaultLow + 1, for: .horizontal)
        rightView.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
    }
    
    @objc func textFieldDidChanged(_ textField: UITextField) {
        guard textField == self.textField else { return }
        searchTextDidChanged?(searchText)
//        delegate?.searchBar(self, textDidChange: searchText)
    }
    
    @objc func didClickedIconImageView(_ sender: UITapGestureRecognizer) {
        didClickedSearch?(searchText)
    }
    
    @objc func didClickedSearchButton(_ sender: UIButton) {
        didClickedSearch?(searchText)
    }
    
    // MARK: - UITextFieldDelegate
    
//    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        return delegate?.searchBarShouldBeginEditing(self) ?? true
//    }
    
//    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        return delegate?.searchBarShouldEndEditing(self) ?? true
//    }
    
//    public func textFieldDidBeginEditing(_ textField: UITextField) {
//        delegate?.searchBarTextDidBeginEditing(self)
//    }
    
//    public func textFieldDidEndEditing(_ textField: UITextField) {
//        delegate?.searchBarTextDidEndEditing(self)
//    }
    
//    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        return delegate?.searchBar(self, shouldChangeTextIn: range, replacementText: string) ?? true
//    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        didClickedClear?("")
//        delegate?.searchBar(self, textDidChange: "")
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didClickedSearch?(searchText)
//        delegate?.searchBarSearchButtonClicked(self)
        textField.resignFirstResponder()
        return true
    }
}
