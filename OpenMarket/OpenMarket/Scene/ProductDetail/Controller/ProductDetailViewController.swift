//
//  ProductDetailViewController.swift
//  OpenMarket
//
//  Created by 1 on 2022/06/08.
//

import UIKit
import RxSwift
import RxCocoa

final class ProductDetailViewController: UIViewController, UICollectionViewDelegate {

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
    private let viewModel = ProductDetailSceneViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureStackViewLayout()
        self.configureCollectionViewFlowLayout()
        self.configureNavigationItem()
        self.layoutImagePageControl()
        self.configureScrollViewdelegate()
        self.bindViewModel()
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
    
    private func configureScrollViewdelegate() {
        guard let scrollView = self.productImageCollectionView as? UIScrollView else {
            return
        }
        scrollView.delegate = self
    }

    // MARK: - Method
    func bindViewModel() {
        let input = ProductDetailSceneViewModel.Input(viewWillAppear: self.rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:))).map{ _ in self.productID!})
        
        let output = viewModel.transform(input: input)
        
        output.prdouctName
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] name in
                self?.configureNavigationTitle(with: name) }
            .disposed(by: disposeBag)
        
        output.productImagesURL
            .observe(on: MainScheduler.instance)
            .bind(to: productImageCollectionView!.rx.items(cellIdentifier: "PrdouctDetailCollectionViewCell", cellType: PrdouctDetailCollectionViewCell.self)) { (row, element, cell) in
                if let imageURL = URL(string: element.thumbnailURL) {
                    cell.fill(with: imageURL) }}
            .disposed(by: disposeBag)
        
        output.productImagesURL
            .observe(on: MainScheduler.instance)
            .subscribe { images in
                self.imagePageControl.numberOfPages = images.count }
            .disposed(by: disposeBag)
        
        output.productPrice
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] price in
                self?.productPriceLabel?.text = price }
            .disposed(by: disposeBag)
        
        output.prodcutSellingPrice
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] sellingPrice in
                self?.productSellingPriceLabel?.text = sellingPrice }
            .disposed(by: disposeBag)
        
        output.productDiscountedRate
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] discountedRate in
                self?.productDiscountRateLabel?.text = discountedRate }
            .disposed(by: disposeBag)
        
        output.productDescription
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] description in
                self?.productDescriptionTextView?.text = description }
            .disposed(by: disposeBag)
        
    }
        
    func setProduct(_ id: Int) {
        self.productID = id
    }
    
    @objc private func presentProductModificationView() {
        guard let productModificationVC = self.storyboard?.instantiateViewController(withIdentifier: "ProductModificationViewController") as? ProductModificationViewController,
        let productID = self.productID else {
            return
        }
        productModificationVC.setProduct(productID)
        self.present(productModificationVC, animated: false)
    }
    
}

// MARK: - UIScrollViewDelegate
extension ProductDetailViewController: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let page = Int(targetContentOffset.pointee.x / self.view.frame.width)
        self.imagePageControl.currentPage = page
    }
}

