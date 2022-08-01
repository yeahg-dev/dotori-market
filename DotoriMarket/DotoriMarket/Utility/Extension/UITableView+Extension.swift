//
//  UITableView+Extension.swift
//  OpenMarket
//
//  Created by lily on 2022/01/20.
//

import UIKit

extension UITableView {
    
    func dequeueReusableCell<T: UITableViewCell>(
        withClass name: T.Type,
        for indexPath: IndexPath
    ) -> T {
        guard let cell = dequeueReusableCell(
            withIdentifier: String(describing: name),
            for: indexPath
        ) as? T else {
            fatalError(
                "Couldn't find UITableViewCell for \(String(describing: name)), make sure the cell is registered with table view")
        }
        return cell
    }
}
