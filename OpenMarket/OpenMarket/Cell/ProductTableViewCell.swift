//
//  ProductTableViewCell.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/13.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

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
        
        if let cachedImage = imageCache.object(forKey: cacheKey) {
            return cachedImage
        }
        
        guard let url = URL(string: url), let imageData = try? Data(contentsOf: url) else {
            let defaultImage = UIImage(systemName: "xmark.icloud")
            return defaultImage?.withTintColor(.systemGray, renderingMode: .alwaysOriginal)
        }
        
        let image = UIImage(data: imageData)!
        imageCache.setObject(image, forKey: cacheKey)
        print("🧡 이미지 캐시됨")
        
        return image
    }
}
