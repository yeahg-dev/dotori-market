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
    private var cancellableTask: Cancellable?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cancellableTask?.cancel()
        self.represntaionLabel?.isHidden = true
    }
    
    func updateProductImageView(image: UIImage?, isRepresentaion: Bool) {
        self.productImageView?.image = image
        self.represntaionLabel?.isHidden = !isRepresentaion
    }
    
    func update(image: UIImage?, url: URL, isRepresentaion: Bool) {
        let invalidImage = UIImage(systemName: "xmark.icloud") ?? UIImage()
        if let image = image {
            self.productImageView?.image = image
        } else {
            self.cancellableTask = self.productImageView?.setImage(with: url, defaultImage: invalidImage)
        }
        self.represntaionLabel?.isHidden = !isRepresentaion
    }
    
}
