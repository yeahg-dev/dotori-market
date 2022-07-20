//
//  ProductTableViewCell.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/13.
//

import UIKit

final class ProductTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var productThumbnail: UIImageView?
    @IBOutlet private weak var productName: UILabel?
    @IBOutlet private weak var productPrice: UILabel?
    @IBOutlet private weak var productBargainPrice: UILabel?
    @IBOutlet private weak var productStock: UILabel?
    
    private var cancellableImageTask: Cancellable?
    
    private let invalidImage: UIImage = {
        let invalidImage = UIImage(systemName: "xmark.icloud") ?? UIImage()
        return invalidImage.withTintColor(.systemGray, renderingMode: .alwaysOriginal)
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
        self.productPrice?.attributedText = product.price
        self.productBargainPrice?.attributedText = product.bargainPrice
        self.productStock?.attributedText = product.stock
    }
}
