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
    @IBOutlet private weak var productPrice: UILabel?
    @IBOutlet private weak var productBargainPrice: UILabel?
    @IBOutlet private weak var productStock: UILabel?
    
    private var cancellableImageTask: Cancellable?
    
    private let invalidImage: UIImage = {
        let invalidImage = UIImage(systemName: "xmark.icloud") ?? UIImage()
        return invalidImage.withTintColor(.systemGray, renderingMode: .alwaysOriginal)
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderColor = UIColor.systemGray.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 5
    }
    
    override func prepareForReuse() {
        productThumbnail?.image = nil
        cancellableImageTask?.cancel()
    }
    
    func fill(with product: ProductViewModel) {
        if let url = URL(string: product.thumbnail) {
            self.cancellableImageTask = productThumbnail?.setImage(
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
