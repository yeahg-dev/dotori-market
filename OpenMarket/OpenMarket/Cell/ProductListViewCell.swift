//
//  ProductListViewCell.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/13.
//

import UIKit

class ProductListViewCell: UITableViewCell {

    @IBOutlet private weak var productThumbnail: UIImageView!
    @IBOutlet private weak var productName: UILabel!
    @IBOutlet private weak var productPrice: UILabel!
    @IBOutlet private weak var productStock: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
