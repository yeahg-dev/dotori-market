//
//  ProductDetailViewController.swift
//  OpenMarket
//
//  Created by 1 on 2022/06/08.
//

import UIKit

final class ProductDetailViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet private weak var productImageCollectionView: UICollectionView?
    @IBOutlet weak var productInfoStackView: UIStackView?
    @IBOutlet private weak var productNameLabel: UILabel?
    @IBOutlet private weak var productPriceLabel: UILabel?
    @IBOutlet weak var productSellingPriceStackView: UIStackView?
    @IBOutlet private weak var productSellingPriceLabel: UILabel?
    @IBOutlet private weak var productDiscountRateLabel: UILabel?
    @IBOutlet weak var productStockLabel: UILabel?
    @IBOutlet private weak var productDescriptionTextView: UITextView?
    
    // MARK: - UI Property
    private let imagePageControl = UIPageControl()
    private let flowLayout = UICollectionViewFlowLayout()
    
    // MARK: - Property
    private let apiService = MarketAPIService()
    private var productID: Int?
    private var productDetail: ProductDetail?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureStackViewLayout()
        self.configureCollectionViewFlowLayout()
        self.configureNavigationItem()
        self.layoutImagePageControl()
        self.downloadProductDetail(prodcutID: productID)
    }
    
    private func configureStackViewLayout() {
        guard let productInfoStackView = self.productInfoStackView,
              let productStockLabel = self.productStockLabel else {
            return
        }

        productInfoStackView.setCustomSpacing(20, after: productStockLabel)
    }

    private func configureCollectionViewFlowLayout() {
        let cellWidth = self.view.frame.width
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        self.productImageCollectionView?.collectionViewLayout = flowLayout
    }
    
    private func configureNavigationItem() {
        let composeButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(presentProductModificationView))
        self.navigationItem.setRightBarButton(composeButton, animated: true)
    }
    
    private func layoutImagePageControl() {
        self.view.addSubview(imagePageControl)
        self.productImageCollectionView?.translatesAutoresizingMaskIntoConstraints = false
        self.imagePageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.imagePageControl.centerXAnchor.constraint(
                equalTo: self.productImageCollectionView!.centerXAnchor),
            self.imagePageControl.bottomAnchor.constraint(
                equalTo: self.productImageCollectionView!.bottomAnchor)
        ])
    }
    
    private func configureNavigationTitle(with title: String) {
        self.navigationItem.title = title
    }

    // MARK: - Method
    func setProduct(_ id: Int) {
        self.productID = id
    }
    
    private func downloadProductDetail(prodcutID: Int?) {
        guard let id = prodcutID else { return }
         
        let request = ProductDetailRequest(productID: id)
        apiService.request(request) { [weak self] (result: Result<ProductDetail, Error>) in
            switch result {
            case .success(let product):
                self?.productDetail = product
                DispatchQueue.main.async {
                    self?.updateProdutDetail(with: product)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func updateProdutDetail(with product: ProductDetail) {
        self.fillUI(with: product)
        self.productImageCollectionView?.reloadData()
    }
    
    private func fillUI(with product: ProductDetail) {
        self.configureNavigationTitle(with: product.name)
        self.productNameLabel?.text = product.name
        self.productPriceLabel?.text = self.productPriceLabelText(of: product)
        self.productDiscountRateLabel?.text = self.productDiscountRateLabelText(of: product)
        self.productSellingPriceLabel?.text = self.productSellingPriceLabelText(of: product)
        self.productStockLabel?.text = self.productStockLabelText(of: product)
        self.productDescriptionTextView?.text = product.description
        self.imagePageControl.numberOfPages = product.images.count
    }
    
    @objc private func presentProductModificationView() {
        guard let productModificationVC = self.storyboard?.instantiateViewController(withIdentifier: "ProductModificationViewController") as? ProductModificationViewController,
        let productID = self.productID else {
            return
        }
        productModificationVC.setProduct(productID)
        productModificationVC.refreshDelegate = self
        self.present(productModificationVC, animated: false)
    }
    
}

// MARK: - UICollectionViewDataSource
extension ProductDetailViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productDetail?.images.count ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = self.productImageCollectionView?.dequeueReusableCell(withReuseIdentifier: "PrdouctDetailCollectionViewCell", for: indexPath) as? PrdouctDetailCollectionViewCell else {
            return PrdouctDetailCollectionViewCell()
        }
        
        if let imageURLString = self.productDetail?.images[indexPath.row].thumbnailURL,
           let imageURL = URL(string: imageURLString) {
            cell.fill(with: imageURL)
        }

        return cell
    }
    
}

// MARK: - UIScrollViewDelegate
extension ProductDetailViewController: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let page = Int(targetContentOffset.pointee.x / self.view.frame.width)
        self.imagePageControl.currentPage = page
    }
}

// MARK: - UILogic
extension ProductDetailViewController {
    
    private func productPriceLabelText(of product: ProductDetail) -> String? {
        if product.discountedPrice.isZero {
            return nil
        }
    
        let price = product.price.decimalFormatted
        let currency = product.currency
        return currency.composePriceTag(of: price)
    }
    
    private func productSellingPriceLabelText(of product: ProductDetail) -> String {
        let price = product.bargainPrice.decimalFormatted
        let currency = product.currency
        return currency.composePriceTag(of: price)
    }
    
    private func productStockLabelText(of product: ProductDetail) -> String {
        if product.stock == .zero {
            return MarketCommon.soldout.rawValue
        }
        let stock = product.stock.decimalFormatted
        return "\(MarketCommon.remainingStock.rawValue) \(stock)"
    }
    
    private func productDiscountRateLabelText(of product: ProductDetail) -> String? {
        if product.discountedPrice.isZero {
            self.productSellingPriceStackView?.spacing = .zero
            return nil
        }
        
        let discountRate = product.discountedPrice / product.price
        return discountRate.decimalFormatted
    }
}

// MARK: - RefreshDelegate
extension ProductDetailViewController: RefreshDelegate {
    func refresh() {
        self.downloadProductDetail(prodcutID: self.productID)
    }
}
