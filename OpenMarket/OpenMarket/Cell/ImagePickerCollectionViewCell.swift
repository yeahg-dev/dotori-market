//
//  ImagePickerCollectionViewCell.swift
//  OpenMarket
//
//  Created by lily on 2022/01/21.
//

import UIKit

final class ImagePickerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var addedImageCountLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderColor = UIColor.systemGray.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 5
    }
    
    func updateAddedImageCountLabel(images: [UIImage]) {
        let maximumImageCount = 5
        let addedImageCount = NSAttributedString(
            string: "\(images.count)",
            attributes: [.font: UIFont.preferredFont(forTextStyle: .callout),
                         .foregroundColor: UIColor.systemIndigo]
        )
        let maximumImageNumber = NSAttributedString(
            string: " / \(maximumImageCount)",
            attributes: [.font: UIFont.preferredFont(forTextStyle: .callout),
                         .foregroundColor: UIColor.systemGray]
        )
        let imageCountLabel = NSMutableAttributedString(attributedString: addedImageCount)
        imageCountLabel.append(maximumImageNumber)
        addedImageCountLabel?.attributedText = imageCountLabel
    }
}
