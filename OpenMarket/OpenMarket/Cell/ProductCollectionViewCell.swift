//
//  ProductCollectionViewCell.swift
//  OpenMarket
//
//  Created by lily on 2022/01/13.
//

import UIKit

class ProductCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: ProductCollectionViewCell.self)
    
    @IBOutlet weak var productThumbnail: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productStock: UILabel!
}
