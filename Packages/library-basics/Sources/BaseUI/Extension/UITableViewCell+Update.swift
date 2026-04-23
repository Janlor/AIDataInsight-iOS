//
//  UITableViewCell+Update.swift
//  ModuleStatistic
//
//  Created by Janlor on 4/22/26.
//

import UIKit

public extension UITableViewCell {
    func updateTableView() {
        if let tableView = self.superview as? UITableView {
            let currentOffset = tableView.contentOffset
            UIView.performWithoutAnimation {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            tableView.setContentOffset(currentOffset, animated: false)
        }
    }
}
