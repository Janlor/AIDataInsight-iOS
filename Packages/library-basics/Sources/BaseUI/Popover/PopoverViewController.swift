//
//  PopoverViewController.swift
//  LibraryCommon
//
//  Created by Janlor on 4/22/26.
//

import UIKit
import BaseKit

public struct PopoverConfiguration {
    let backgroundColor: UIColor
    let selectedBackgroundColor: UIColor
    let tintColor: UIColor
    let titleColor: UIColor
    let separatorColor: UIColor
    let titleFont: UIFont
    let rowHeight: CGFloat
    
    static var `default`: PopoverConfiguration {
        PopoverConfiguration(
            backgroundColor: .theme.background,
            selectedBackgroundColor: .theme.secondaryBackground,
            tintColor: .theme.label,
            titleColor: .theme.label,
            separatorColor: .theme.separator,
            titleFont: .theme.subhead,
            rowHeight: 40.0)
    }
}

public class PopoverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    public typealias DidSelectIndex = ((_ index: Int) -> Void)
    public var didSelectIndex: DidSelectIndex?
    
    public var options: [String]!
    public var images: [UIImage]?
    
    private var config: PopoverConfiguration = .default
    
    public init(config: PopoverConfiguration? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.config = config ?? .default
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = config.backgroundColor
        
        let tableView = PanSelectionTableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
        tableView.rowHeight = config.rowHeight
        tableView.separatorColor = config.separatorColor
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.selectionStyle = .default
        cell.selectedBackgroundView = UIView(frame: cell.bounds)
        cell.selectedBackgroundView?.backgroundColor = config.selectedBackgroundColor
        cell.textLabel?.text = options[indexPath.row]
        cell.textLabel?.font = config.titleFont
        cell.textLabel?.textColor = config.tintColor
        if let images = images, indexPath.row < images.count {
            let image = images[indexPath.row]
            cell.imageView?.image = image.withRenderingMode(.alwaysTemplate)
            cell.imageView?.tintColor = config.tintColor
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        appLog("Selected: \(options[indexPath.row])")
        dismiss(animated: true) { [weak self] in
            if let didSelectIndex = self?.didSelectIndex {
                didSelectIndex(indexPath.row)
            }
        }
    }
}
