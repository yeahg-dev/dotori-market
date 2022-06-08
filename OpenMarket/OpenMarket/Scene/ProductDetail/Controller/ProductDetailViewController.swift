//
//  ProductDetailViewController.swift
//  OpenMarket
//
//  Created by 1 on 2022/06/08.
//

import UIKit

final class ProductDetailViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet private weak var prductImageCollectionView: UICollectionView?
    @IBOutlet private weak var productName: UILabel?
    @IBOutlet private weak var productPrice: UILabel?
    @IBOutlet private weak var productSellingPrice: UILabel?
    @IBOutlet private weak var discountRate: UILabel?
    @IBOutlet private weak var productDescription: UITextView?
    
    // MARK: - UI Property
    private let imagePageControl = UIPageControl()
    
    // MARK: - Property
    private var productID: Int?
    private var productDetail: ProductDetail?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.layoutImagePageControl()
    }
    
    private func layoutImagePageControl() {
        self.prductImageCollectionView?.addSubview(imagePageControl)
        self.imagePageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.imagePageControl.centerXAnchor.constraint(
                equalTo: self.prductImageCollectionView!.centerXAnchor),
            self.imagePageControl.bottomAnchor.constraint(
                equalTo: self.prductImageCollectionView!.bottomAnchor)
        ])
    }

    // MARK: - Method
    func setProduct(_ id: Int) {
        self.productID = id
    }
}
