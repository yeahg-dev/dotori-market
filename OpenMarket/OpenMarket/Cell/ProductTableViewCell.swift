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
    
    override func prepareForReuse() {
        productThumbnail?.image = nil
    }
    
    func configureTableContent(with product: Product) {
        DispatchQueue.main.async {
            self.productThumbnail?.image = self.getImage(from: product.thumbnail)
        }
        productName?.attributedText = product.attributedName
        productPrice?.attributedText = product.attributedPrice
        productStock?.attributedText = product.attributedStock
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
