//
//  PrdouctDetailCollectionViewCell.swift
//  OpenMarket
//
//  Created by 1 on 2022/06/09.
//

import UIKit

final class PrdouctDetailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var prdouctImage: UIImageView!
    
    private let invalidImage = UIImage(systemName: "xmark.icloud.fill")
    private var cancellableImageTask: Cancellable?
    
    override func prepareForReuse() {
        self.prdouctImage?.image = nil
        self.cancellableImageTask?.cancel()
    }
    
    func fill(with imageURL: URL) {
        self.cancellableImageTask = prdouctImage.setImage(with: imageURL, invalidImage: invalidImage!)
    }
    
}
