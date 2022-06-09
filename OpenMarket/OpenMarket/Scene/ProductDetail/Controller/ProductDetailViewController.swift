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
    @IBOutlet private weak var productNameLabel: UILabel?
    @IBOutlet private weak var productPriceLabel: UILabel?
    @IBOutlet private weak var productSellingPriceLabel: UILabel?
    @IBOutlet private weak var discountRateLabel: UILabel?
    @IBOutlet weak var productStockLabel: UILabel?
    @IBOutlet private weak var productDescriptionTextView: UITextView?
    
    // MARK: - UI Property
    private let imagePageControl = UIPageControl()
    private let flowLayout = UICollectionViewFlowLayout()
    
    // MARK: - Property
    private let apiService = APIExecutor()
    private var productID: Int?
    private var productDetail: ProductDetail?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionViewFlowLayout()
        self.configureNavigationItem()
        self.layoutImagePageControl()
        self.downloadProductDetail(prodcutID: productID)
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
        let composeButton = UIBarButtonItem(barButtonSystemItem: .compose, target: nil, action: nil)
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
        apiService.execute(request) { [weak self] (result: Result<ProductDetail, Error>) in
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
        self.productPriceLabel?.text = product.price.description
        self.productSellingPriceLabel?.text = product.bargainPrice.description
        self.productStockLabel?.text = "남은 수량: \(product.stock.description)개"
        self.productDescriptionTextView?.text = "상품설명"
        self.imagePageControl.numberOfPages = product.images.count
    }
    
}

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

extension ProductDetailViewController: UICollectionViewDelegate {
    
}

