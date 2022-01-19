//
//  ProductCollectionViewCell.swift
//  OpenMarket
//
//  Created by lily on 2022/01/13.
//

import UIKit

class ProductCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var productThumbnail: UIImageView?
    @IBOutlet private weak var productName: UILabel?
    @IBOutlet private weak var productPrice: UILabel?
    @IBOutlet private weak var productStock: UILabel?
    
    private let invalidImage: UIImage = {
        let invalidImage = UIImage(systemName: "xmark.icloud") ?? UIImage()
        invalidImage.withTintColor(.systemGray, renderingMode: .alwaysOriginal)
        return invalidImage
    }()
    
    func configureCollectionContent(with product: Product) {
        if let url = URL(string: product.thumbnail) {
            productThumbnail?.setImage(with: url, invalidImage: invalidImage)
        }
        productName?.attributedText = product.attributedName
        productPrice?.attributedText = product.attributedPrice
        productStock?.attributedText = product.attributedStock
    }
   
    func configureCollectionCellLayer() {
        self.layer.borderColor = UIColor.systemGray.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5
    }
}
