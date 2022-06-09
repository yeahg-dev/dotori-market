//
//  ProductModificationViewController.swift
//  OpenMarket
//
//  Created by 1 on 2022/06/09.
//

import UIKit

class ProductModificationViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var productImageCollectionView: UICollectionView?
    @IBOutlet weak var productNameLabel: UITextField?
    @IBOutlet weak var prdouctPriceLabel: UITextField?
    @IBOutlet weak var productCurrencySegmentedControl: UISegmentedControl?
    @IBOutlet weak var productDisconutPriceLabel: UITextField?
    @IBOutlet weak var productStockLabel: UITextField?
    @IBOutlet weak var productDescriptionTextView: UITextView?
    
    // MARK: - Property
    private let apiService = APIExecutor()
    private var productID: Int?
    private var productDetail: ProductDetail?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.downloadProductDetail(of: productID)
    }
    
    // MARK: - IBAction
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    // MARK: -Method
    func setProduct(_ productID: Int) {
        self.productID = productID
    }
    
    private func downloadProductDetail(of prodcutID: Int?) {
        guard let id = prodcutID else { return }
        
        let request = ProductDetailRequest(productID: id)
        apiService.execute(request) { [weak self] (result: Result<ProductDetail, Error>) in
            switch result {
            case .success(let product):
                self?.productDetail = product
                DispatchQueue.main.async {
                    self?.updateProdutDetail(wtih: product)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func updateProdutDetail(wtih product: ProductDetail) {
        self.productNameLabel?.text = product.name
        self.prdouctPriceLabel?.text = product.price.formatted()
        self.productDisconutPriceLabel?.text  = product.discountedPrice.formatted()
        self.productStockLabel?.text = product.stock.formatted()
        self.productDescriptionTextView?.text = product.description
        let currency = product.currency
        switch currency {
        case .krw:
            self.productCurrencySegmentedControl?.selectedSegmentIndex = 0
        case .usd:
            self.productCurrencySegmentedControl?.selectedSegmentIndex = 1
        }
    }
    
}

extension ProductModificationViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = self.productImageCollectionView?.dequeueReusableCell(withReuseIdentifier: "ProductImageCollectionViewCell", for: indexPath) as? ProductImageCollectionViewCell else {
            return ProductImageCollectionViewCell()
        }
        
        return cell
    }

}
