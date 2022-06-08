//
//  ProductDetailImageCollectionViewCell.swift
//  OpenMarket
//
//  Created by 1 on 2022/06/08.
//

import UIKit

final class ProductDetailImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var productImage: UIImageView?
    
    func updateProductImage(with image: UIImage) {
        self.productImage?.image = image
    }
}
