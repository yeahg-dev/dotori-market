//
//  ProductImageCollectionViewCell.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/21.
//

import UIKit

final class ProductImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var productImageView: UIImageView?
    
    func updateProductImageView(image: UIImage?) {
        productImageView?.image = image
    }
}
