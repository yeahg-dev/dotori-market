//
//  ProductGridViewCell.swift
//  OpenMarket
//
//  Created by lily on 2022/01/13.
//

import UIKit

class ProductGridViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: ProductGridViewCell.self)
    
    @IBOutlet private weak var productThumbnail: UIImageView!
    @IBOutlet private weak var productName: UILabel!
    @IBOutlet private weak var productPrice: UILabel!
    @IBOutlet private weak var productStock: UILabel!
}
