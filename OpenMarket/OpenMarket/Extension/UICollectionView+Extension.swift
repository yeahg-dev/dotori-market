//
//  UICollectionView+Extension.swift
//  OpenMarket
//
//  Created by lily on 2022/01/20.
//

import UIKit

extension UICollectionView {
    
    func dequeueReusableCell<T: UICollectionViewCell>(
        withClass name: T.Type,
        for indexPath: IndexPath
    ) -> T {
        guard let cell = dequeueReusableCell(
            withReuseIdentifier: String(describing: name),
            for: indexPath
        ) as? T else {
            fatalError(
                "Couldn't find UICollectionViewCell for \(String(describing: name)), make sure the cell is registered with collection view")
        }
        return cell
    }
}
