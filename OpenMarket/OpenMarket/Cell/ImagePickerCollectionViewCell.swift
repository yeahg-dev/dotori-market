//
//  ImagePickerCollectionViewCell.swift
//  OpenMarket
//
//  Created by lily on 2022/01/21.
//

import UIKit

final class ImagePickerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var addedImageCountLabel: UILabel?
    
    func updateAddedImageCountLabel(images: [UIImage]) {
        addedImageCountLabel?.text = "\(images.count) / 5"
    }
}
