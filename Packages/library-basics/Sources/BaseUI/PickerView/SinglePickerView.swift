//
//  SinglePickerView.swift
//  LibraryCommon
//
//  Created by Janlor on 4/22/26.
//

import UIKit

/// 轮子型选择器
//let picker = SinglePickerView<SelectorOptions>()
//picker.title = "标题"
//picker.didSelectObject = { object in
//    appLog(object)
//}
//picker.displayValueFor = { value in
//    return value?.displayText
//}
//picker.options = options
//picker.value = options[2]
//picker.show()
public class SinglePickerView<T> : BasePickerView, UIPickerViewDataSource, UIPickerViewDelegate where T: Equatable {
    
    public var rowHeight = 44.0
    public var pickerTextAttributes: [NSAttributedString.Key: Any]?
    
    public typealias DidSelectObject = ((_ object: T) -> Void)
    public var didSelectObject: DidSelectObject?
    
    public var value: T?
    public var options = [T]() {
        didSet {
            picker.reloadAllComponents()
            DispatchQueue.main.async {
                self.selectDefaultRow()
            }
        }
    }
    /// Block variable used to get the String that should be displayed for the value of this row.
    public var displayValueFor: ((T?) -> String?)? = {
        return $0.map { String(describing: $0) }
    }
    
    private lazy var picker: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        return pickerView
    }()
    
    // MARK: - Override
    
    /// 点击了保存按钮
    public override func didClickedCommitButton(_ sender: UIButton) {
        super.didClickedCommitButton(sender)
        
        let row = picker.selectedRow(inComponent: 0)
        guard row >= 0 && row < options.count else {
            hidden()
            return
        }
        
        if let closure = didSelectObject {
            closure(options[row])
            hidden()
        }
    }
    
    public override func setupUI() {
        super.setupUI()
        pickerTextAttributes = [
            .foregroundColor: UIColor.theme.label,
            .font: UIFont.theme.body
        ]
    }
    
    public override func addSubviews() {
        super.addSubviews()
        bottomView.addSubview(picker)
        picker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            picker.leadingAnchor.constraint(equalTo: bottomView.readableContentGuide.leadingAnchor, constant: mSpacing - 8),
            picker.trailingAnchor.constraint(equalTo: bottomView.readableContentGuide.trailingAnchor, constant: -mSpacing + 8),
            picker.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Spacing.medium),
            picker.bottomAnchor.constraint(equalTo: bottomView.safeAreaLayoutGuide.bottomAnchor),
            picker.heightAnchor.constraint(equalToConstant: rowHeight * 5.0)
        ])
    }
    
    // MARK: - Delegate

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        options.count
    }

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        displayValueFor?(options[row])
    }
    
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        guard let pickerTextAttributes = pickerTextAttributes, let text = self.pickerView(pickerView, titleForRow: row, forComponent: component) else {
            return nil
        }
        return NSAttributedString(string: text, attributes: pickerTextAttributes)
    }
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        rowHeight
    }
    
    deinit {
        picker.delegate = nil
        picker.dataSource = nil
    }
}

private extension SinglePickerView {
    func selectDefaultRow() {
        if let v = value, let row = options.firstIndex(of: v) {
            picker.selectRow(row, inComponent: 0, animated: false)
        }
    }
}
