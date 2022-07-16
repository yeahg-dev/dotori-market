//
//  UITableViewController+Extension.swift
//  OpenMarket
//
//  Created by lily on 2022/01/25.
//

import UIKit

extension UITableViewController {
    
    func scrollToTop(animated: Bool) {
        let topRow = IndexPath(row: .zero, section: .zero)
        self.tableView.scrollToRow(at: topRow, at: .top, animated: animated)
    }
}
