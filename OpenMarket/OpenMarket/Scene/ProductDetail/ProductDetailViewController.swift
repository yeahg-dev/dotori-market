//
//  ProductDetailViewController.swift
//  OpenMarket
//
//  Created by 1 on 2022/06/08.
//

import UIKit

class ProductDetailViewController: UIViewController {

    @IBOutlet weak var prductImageCollectionView: UICollectionView?
    @IBOutlet weak var productName: UILabel?
    @IBOutlet weak var productPrice: UILabel?
    @IBOutlet weak var productSellingPrice: UILabel?
    @IBOutlet weak var discountRate: UILabel?
    @IBOutlet weak var productDescription: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
