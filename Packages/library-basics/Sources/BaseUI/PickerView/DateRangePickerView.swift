//
//  DateRangePickerView.swift
//  LibraryCommon
//
//  Created by Janlor on 5/28/24.
//

import UIKit
import AudioToolbox.AudioServices

public class DateRangePickerView : BasePickerView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    public typealias DidSelectedDate = ((_ start: Date?, _ end: Date?) -> Void)
    public var didSelectedDate: DidSelectedDate?
    
    private let rowHeight: CGFloat = 38.0
    private let minLineSpacing: CGFloat = 2.0
    private var sectionInset: CGFloat {
        return mSpacing - 6
    }
    
    private lazy var monthLabel: UILabel = {
        let label = UILabel()
        label.textColor = .theme.label
        label.themeFont = .theme.body
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var lastMonthButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage.imageNamed(for: "BaseUI_arrow_left"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(didClickedLastMonthButton(_:)), for: .touchUpInside)
        return btn
    }()
    private lazy var nextMonthButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage.imageNamed(for: "BaseUI_arrow_right"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(didClickedNextMonthButton(_:)), for: .touchUpInside)
        return btn
    }()
    private lazy var weekStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = minLineSpacing
        layout.minimumInteritemSpacing = 0.0
        layout.sectionInset = .zero
        return layout
    }()
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.delegate = self
        view.dataSource = self
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.register(DateRangePickerCell.self, forCellWithReuseIdentifier: DateRangePickerCell.identifier)
        return view
    }()
    private lazy var feedbackGenerator: UISelectionFeedbackGenerator = {
        let f = UISelectionFeedbackGenerator()
        f.prepare()
        return f
    }()
    
    private var startDate: Date?
    private var endDate: Date?
    private var currentMonth: Date! {
        didSet {
            appDateFormatter.dateFormat = NSLocalizedString("yyyy年MM月", bundle: .module, comment: "")
            monthLabel.text = appDateFormatter.string(from: currentMonth)
        }
    }
    private let calendar = Calendar.current
    private let weekTitles = [
        NSLocalizedString("日", bundle: .module, comment: ""),
        NSLocalizedString("一", bundle: .module, comment: ""),
        NSLocalizedString("二", bundle: .module, comment: ""),
        NSLocalizedString("三", bundle: .module, comment: ""),
        NSLocalizedString("四", bundle: .module, comment: ""),
        NSLocalizedString("五", bundle: .module, comment: ""),
        NSLocalizedString("六", bundle: .module, comment: "")
    ]
    
//    private let maxDate: Date
//    private let minDate: Date
//    private let maxDays: Int
    
//    public init(maxDate: Date, minDate: Date, maxDays: Int) {
//        self.maxDate = maxDate
//        self.minDate = minDate
//        self.maxDays = maxDays
//        super.init(frame: .zero)
//    }
    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    // MARK: - Override
    
    /// 点击了保存按钮
    public override func didClickedCommitButton(_ sender: UIButton) {
        super.didClickedCommitButton(sender)
        // 当天开始当前结束
        if startDate != nil, endDate == nil {
            endDate = startDate
        }
        
        if let closure = didSelectedDate {
            closure(startDate, endDate)
        }
        hidden()
    }
    
    @objc func didClickedLastMonthButton(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        changeMonth(by: -1)
        sender.isUserInteractionEnabled = true
    }
    
    @objc func didClickedNextMonthButton(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        changeMonth(by: 1)
        sender.isUserInteractionEnabled = true
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
    }
    
    public override func setupUI() {
        super.setupUI()
        self.currentMonth = Date()
        setupGestureRecognizers()
    }
    
    public override func addSubviews() {
        super.addSubviews()
        
        bottomView.addSubview(monthLabel)
        NSLayoutConstraint.activate([
            monthLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Spacing.medium),
            monthLabel.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor),
            monthLabel.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        bottomView.addSubview(lastMonthButton)
        NSLayoutConstraint.activate([
            lastMonthButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            lastMonthButton.trailingAnchor.constraint(equalTo: bottomView.centerXAnchor, constant: -80)
        ])
        
        bottomView.addSubview(nextMonthButton)
        NSLayoutConstraint.activate([
            nextMonthButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            nextMonthButton.leadingAnchor.constraint(equalTo: bottomView.centerXAnchor, constant: 80)
        ])
        
        bottomView.addSubview(weekStackView)
        NSLayoutConstraint.activate([
            weekStackView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 12),
            weekStackView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: sectionInset),
            weekStackView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -sectionInset),
            weekStackView.heightAnchor.constraint(equalToConstant: rowHeight)
        ])
        
        bottomView.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: weekStackView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: sectionInset),
            collectionView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -sectionInset),
            collectionView.bottomAnchor.constraint(equalTo: bottomView.safeAreaLayoutGuide.bottomAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: rowHeight * 6 + 5 * minLineSpacing)
        ])
        
        for title in weekTitles {
            let label = UILabel()
            label.text = title
            label.textAlignment = .center
            label.textColor = .theme.secondaryLabel
            label.themeFont = .theme.subhead
            weekStackView.addArrangedSubview(label)
        }
    }
    
    // MARK: - Delegate
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 42 // 6 weeks to display all possible dates in a month
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DateRangePickerCell.identifier, for: indexPath) as! DateRangePickerCell
        
        guard let date = dateFromIndexPath(indexPath) else {
            cell.configure(with: nil, style: .disabled)
            return cell
        }
        
        let isCurrentMonth = isDateInCurrentMonth(date)
        let isSelected = isSelectedDate(date)
        
        var style: DateRangePickerCell.CellStyle = .disabled
        if !isCurrentMonth {
            style = .disabled
        } else if isSelected {
            if endDate == nil {
                style = .single
            } else if date == startDate {
                style = .first
            } else if date == endDate {
                style = .last
            } else {
                style = .center
            }
        } else {
            style = .normal
        }
        
        cell.configure(with: date, style: style)
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let date = dateFromIndexPath(indexPath), date >= minDate, date <= maxDate else { return }
        guard let date = dateFromIndexPath(indexPath) else { return }
        let isCurrentMonth = isDateInCurrentMonth(date)
        guard isCurrentMonth else { return }
        
        if startDate == nil {
            startDate = date
        } else if let sDate = startDate, endDate == nil {
            if date < sDate {
                startDate = date
            } else if date == sDate {
                startDate = nil
            } else {
                endDate = date
            }
        } else {
            startDate = date
            endDate = nil
        }
        
        collectionView.reloadData()
        selectionChanged()
    }
    
    func selectionChanged() {
        // 播放声音
        AudioServicesPlaySystemSound(1104) // 1104 对应于 `Tock.aiff`
        feedbackGenerator.selectionChanged()
        feedbackGenerator.prepare()
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.size.width) / 7.0
        return CGSize(width: width, height: rowHeight)
    }
    
    deinit {
        collectionView.delegate = nil
        collectionView.dataSource = nil
    }
}

private extension DateRangePickerView {
    private func setupGestureRecognizers() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(gesture:)))
        swipeLeft.direction = .left
        collectionView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(gesture:)))
        swipeRight.direction = .right
        collectionView.addGestureRecognizer(swipeRight)
    }
    
    @objc private func handleSwipe(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            changeMonth(by: 1)
        } else if gesture.direction == .right {
            changeMonth(by: -1)
        }
    }
    
    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
            collectionView.reloadData()
            selectionChanged()
        }
    }
    
    private func dateFromIndexPath(_ indexPath: IndexPath) -> Date? {
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1
        let daysOffset = indexPath.item - firstWeekday
        return calendar.date(byAdding: .day, value: daysOffset, to: firstDayOfMonth)
    }
    
    private func firstDayOfMonthOffset() -> Int {
        let components = calendar.dateComponents([.year, .month], from: currentMonth)
        let firstDay = calendar.date(from: components)!
        return calendar.component(.weekday, from: firstDay) - 1
    }
    
    private func daysInMonth(_ date: Date) -> Int {
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }
    
    private func isDateInCurrentMonth(_ date: Date) -> Bool {
        return calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }
    
    private func isSelectedDate(_ date: Date) -> Bool {
        guard let startDate = startDate else { return false }
        if let endDate = endDate {
            return date >= startDate && date <= endDate
        } else {
            return date == startDate
        }
    }
}

// MARK: - DateRangePickerCell

class DateRangePickerCell: UICollectionViewCell {
    static let identifier = "DateRangePickerCell"
    
    enum CellStyle {
        case normal, disabled, first, last, center, single
    }
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(dateLabel)
        NSLayoutConstraint.activate([
            dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with date: Date?, style: CellStyle) {
        if let date = date {
            appDateFormatter.dateFormat = "d"
            dateLabel.text = appDateFormatter.string(from: date)
        } else {
            dateLabel.text = nil
        }
        
        switch style {
        case .normal:
            dateLabel.textColor = .theme.label
            contentView.backgroundColor = .clear
            contentView.layer.cornerRadius = 0
        case .first:
            dateLabel.textColor = .white
            contentView.backgroundColor = .theme.accent
            contentView.layer.cornerRadius = 18
            contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        case .center:
            dateLabel.textColor = .white
            contentView.backgroundColor = .theme.accent
            contentView.layer.cornerRadius = 0
        case .last:
            dateLabel.textColor = .white
            contentView.backgroundColor = .theme.accent
            contentView.layer.cornerRadius = 18
            contentView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        case .single:
            dateLabel.textColor = .white
            contentView.backgroundColor = .theme.accent
            contentView.layer.cornerRadius = 18
            contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        case .disabled:
            dateLabel.textColor = .theme.quaternaryLabel
            contentView.backgroundColor = .clear
            contentView.layer.cornerRadius = 0
        }
    }
}
