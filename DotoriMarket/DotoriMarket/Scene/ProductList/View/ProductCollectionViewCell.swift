//
//  ProductCollectionViewCell.swift
//  OpenMarket
//
//  Created by lily on 2022/01/13.
//

import UIKit

final class ProductCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var productThumbnail: UIImageView?
    @IBOutlet private weak var productName: UILabel?
    @IBOutlet private weak var productDiscountedRateLabel: UILabel?
    @IBOutlet private weak var productSellingPriceLabel: UILabel?
    @IBOutlet weak var productStockLabel: UILabel!
    
    private var cancellableImageTask: Cancellable?
    
    private let invalidImage: UIImage = {
        let invalidImage = UIImage(systemName: "photo.fill") ?? UIImage()
        return invalidImage.withTintColor(.systemBrown, renderingMode: .alwaysOriginal)
    }()
    
    override func prepareForReuse() {
        self.productThumbnail?.image = nil
        self.cancellableImageTask?.cancel()
    }
    
    func fillContent(of product: ProductViewModel) {
        if let url = URL(string: product.thumbnail) {
            self.cancellableImageTask = self.productThumbnail?.setImage(
                with: url,
                invalidImage: invalidImage
            )
        }
        self.productName?.text = product.name
        self.productSellingPriceLabel?.text = product.sellingPrice
        self.productStockLabel.attributedText = product.stock
        guard let _ = product.discountedRate else {
            self.productDiscountedRateLabel?.isHidden = true
            return
        }
        self.productDiscountedRateLabel?.text = product.discountedRate
    }
}
