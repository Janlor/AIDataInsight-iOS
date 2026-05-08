//
//  SettingViewController.swift
//  LibraryCommon
//
//  Created by Janlor on 5/1/26.
//

import UIKit
import BaseUI
import Router
import Environment
import AccountProtocol
import PrivacyProtocol

final class SettingViewController: BaseViewController {
    private let viewModel = SettingViewModel()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.register(SettingItemCell.self, forCellReuseIdentifier: SettingItemCell.reuseIdentifier)
        return tableView
    }()

    override func setupUI() {
        super.setupUI()
        bindViewModel()
        title = NSLocalizedString("设置", bundle: .module, comment: "")
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapCloseButton)
        )

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        setupBackground()
    }

    override func setupData() {
        super.setupData()
        reloadData()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadData),
            name: .userDidUpdate,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

private extension SettingViewController {
    @objc func didTapCloseButton() {
        quit()
    }

    @objc func reloadData() {
        viewModel.reloadData()
    }

    func didSelectAction(_ action: SettingItemAction) {
        switch action {
        case .updatePassword:
            Router.perform(key: AccountRouteService.self)?.toUpdatePassword(from: self)
        case .privacy:
            let urlString = Environment.server.privacyPolicyURL
            Router.push(from: self, to: PrivacyProtocol.self, animated: true)?
                .insert(params: ["urlString": urlString])
        case .logout:
            showLogoutAlert()
        }
    }

    func showLogoutAlert() {
        let title = NSLocalizedString("确认注销并退出系统吗？", bundle: .module, comment: "")
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.view.tintColor = .theme.label
        alert.addAction(UIAlertAction(title: NSLocalizedString("取消", bundle: .module, comment: ""), style: .cancel))
        alert.addAction(UIAlertAction(title: NSLocalizedString("确定", bundle: .module, comment: ""), style: .destructive) { [weak self] _ in
            self?.logoutAction()
        })
        present(alert, animated: true)
    }

    func logoutAction() {
        Task {
            await viewModel.logout()
        }
    }
}

private extension SettingViewController {
    func bindViewModel() {
        viewModel.onReload = { [weak self] in
            self?.tableView.reloadData()
        }
        viewModel.onError = { message in
            ProgressHUD.showError(withStatus: message)
        }
    }
}

extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingItemCell.reuseIdentifier, for: indexPath)
        guard let settingCell = cell as? SettingItemCell,
              let item = viewModel.item(at: indexPath) else {
            return cell
        }
        settingCell.configure(with: item)
        return settingCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let action = viewModel.item(at: indexPath)?.action else { return }
        didSelectAction(action)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.section(at: section)?.headerTitle
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        viewModel.section(at: section)?.footerTitle
    }
}

private final class SettingItemCell: UITableViewCell {
    static let reuseIdentifier = "SettingItemCell"

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let contentStack = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        accessoryType = .none
        iconView.isHidden = true
        titleLabel.textAlignment = .left
        titleLabel.textColor = .theme.label
        detailLabel.text = nil
    }

    func configure(with model: SettingItemViewData) {
        selectionStyle = model.isSelectable ? .default : .none
        iconView.image = model.iconSystemName.map { UIImage(systemName: $0)?.withRenderingMode(.alwaysTemplate) } ?? nil
        iconView.tintColor = model.isDestructive ? .systemRed : .theme.secondaryLabel
        iconView.isHidden = model.iconSystemName == nil

        titleLabel.text = model.title
        titleLabel.textColor = model.isDestructive ? .systemRed : .theme.label
        titleLabel.textAlignment = model.centeredTitle ? .center : .left

        detailLabel.text = model.detail
        detailLabel.isHidden = model.detail == nil

        accessoryType = model.showsDisclosureIndicator ? .disclosureIndicator : .none
        contentStack.setCustomSpacing(model.iconSystemName == nil ? 0 : 12, after: iconView)
    }

    private func setupUI() {
        backgroundColor = .theme.secondaryGroupedBackground

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20)
        ])

        titleLabel.font = .theme.body
        titleLabel.textColor = .theme.label

        detailLabel.font = .theme.subhead
        detailLabel.textColor = .theme.secondaryLabel
        detailLabel.textAlignment = .right
        detailLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .horizontal
        contentStack.alignment = .center
        contentStack.spacing = 12
        contentStack.addArrangedSubview(iconView)
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(detailLabel)
        contentView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14)
        ])
    }
}
