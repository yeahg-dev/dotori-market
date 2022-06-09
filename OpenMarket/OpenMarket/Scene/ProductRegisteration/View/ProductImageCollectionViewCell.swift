//
//  ProductImageCollectionViewCell.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/21.
//

import UIKit

final class ProductImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var productImageView: UIImageView?
    @IBOutlet private weak var represntaionLabel: UILabel?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.represntaionLabel?.isHidden = true
    }
    
    func updateProductImageView(image: UIImage?, isRepresentaion: Bool) {
        self.productImageView?.image = image
        self.represntaionLabel?.isHidden = !isRepresentaion
    }
    
}
