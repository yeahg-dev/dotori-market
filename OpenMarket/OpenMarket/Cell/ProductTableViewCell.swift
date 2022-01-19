//
//  ProductTableViewCell.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/13.
//

import UIKit

class ProductTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var productThumbnail: UIImageView?
    @IBOutlet private weak var productName: UILabel?
    @IBOutlet private weak var productPrice: UILabel?
    @IBOutlet private weak var productStock: UILabel?
    
    private let invalidImage: UIImage = {
        let invalidImage = UIImage(systemName: "xmark.icloud") ?? UIImage()
        invalidImage.withTintColor(.systemGray, renderingMode: .alwaysOriginal)
        return invalidImage
    }()
    
    override func prepareForReuse() {
        productThumbnail?.image = nil
    }
    
    func configureTableContent(with product: Product) {
        if let url = URL(string: product.thumbnail) {
            productThumbnail?.setImage(with: url, invalidImage: invalidImage)
        }
        productName?.attributedText = product.attributedName
        productPrice?.attributedText = product.attributedPrice
        productStock?.attributedText = product.attributedStock
    }
}
