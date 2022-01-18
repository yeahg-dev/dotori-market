//
//  ProductTableViewCell.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/13.
//

import UIKit

class ProductTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: ProductTableViewCell.self)
    
    @IBOutlet weak var productThumbnail: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productStock: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
