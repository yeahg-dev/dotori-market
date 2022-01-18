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
    
    func configureCollectionContent(with product: Product) {
        DispatchQueue.main.async {
            self.productThumbnail?.image = self.getImage(from: product.thumbnail)
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
    
    private func getImage(from url: String) -> UIImage? {
        let cacheKey = NSString(string: url)
        if let cachedImage = ImageCacheManager.share.object(forKey: cacheKey) {
            return cachedImage
        }
        let defaultImage = UIImage(systemName: "xmark.icloud")
        return defaultImage?.withTintColor(.systemGray, renderingMode: .alwaysOriginal)
    }
}
