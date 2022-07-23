//
//  ProductTableViewCell.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/13.
//

import UIKit

final class ProductTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var productThumbnailImageView: UIImageView?
    @IBOutlet private weak var productNameLabel: UILabel?
    @IBOutlet private weak var productSellingPriceLabel: UILabel?
    @IBOutlet private weak var productStockLabel: UILabel?
    @IBOutlet private weak var ProductDiscountedRateLabel: UILabel?
    
    private var cancellableImageTask: Cancellable?
    
    private let invalidImage: UIImage = {
        let invalidImage = UIImage(systemName: "photo.fill") ?? UIImage()
        return invalidImage.withTintColor(.systemBrown, renderingMode: .alwaysOriginal)
    }()
    
    override func prepareForReuse() {
        self.productThumbnailImageView?.image = nil
        self.ProductDiscountedRateLabel?.isHidden = false
        self.cancellableImageTask?.cancel()
    }
    
    func fillContent(of product: ProductViewModel) {
        if let url = URL(string: product.thumbnail) {
            self.cancellableImageTask = self.productThumbnailImageView?.setImage(
                with: url,
                invalidImage: invalidImage
            )
        }
        self.productNameLabel?.text = product.name
        self.productSellingPriceLabel?.text = product.sellingPrice
        self.productStockLabel?.attributedText = product.stock
        guard let _ = product.discountedRate else {
            self.ProductDiscountedRateLabel?.isHidden = true
            return
        }
        self.ProductDiscountedRateLabel?.text = product.discountedRate
    }
}
