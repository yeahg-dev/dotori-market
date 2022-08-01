//
//  UICollectionViewController+Extension.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/25.
//

import UIKit

extension UICollectionViewController {
    
    func scrollToFirstItem(animated: Bool) {
        let firstItem = IndexPath(item: .zero, section: .zero)
        self.collectionView.scrollToItem(at: firstItem, at: .top, animated: animated)
    }
}
