//
//  ImagePickerCollectionViewCell.swift
//  DotoriMarket
//
//  Created by lily on 2022/01/21.
//

import UIKit

final class ImagePickerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var addedImageCountLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor.systemGray.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5
    }
    
    func updateAddedImageCountLabel(productImageCount: Int) {
        let maximumImageCount = 5
        let addedImageCount = NSAttributedString(
            string: "\(productImageCount)",
            attributes: [.font: UIFont.preferredFont(forTextStyle: .callout),
                         .foregroundColor: DotoriColorPallete.identityColor]
        )
        let maximumImageNumber = NSAttributedString(
            string: " / \(maximumImageCount)",
            attributes: [.font: UIFont.preferredFont(forTextStyle: .callout),
                         .foregroundColor: UIColor.systemGray]
        )
        let imageCountLabel = NSMutableAttributedString(attributedString: addedImageCount)
        imageCountLabel.append(maximumImageNumber)
        self.addedImageCountLabel?.attributedText = imageCountLabel
    }
}
