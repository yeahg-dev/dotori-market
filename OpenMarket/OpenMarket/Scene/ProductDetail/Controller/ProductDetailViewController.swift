//
//  ProductDetailViewController.swift
//  OpenMarket
//
//  Created by 1 on 2022/06/08.
//

import UIKit

final class ProductDetailViewController: UIViewController {

    @IBOutlet private weak var prductImageCollectionView: UICollectionView?
    @IBOutlet private weak var productName: UILabel?
    @IBOutlet private weak var productPrice: UILabel?
    @IBOutlet private weak var productSellingPrice: UILabel?
    @IBOutlet private weak var discountRate: UILabel?
    @IBOutlet private weak var productDescription: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
