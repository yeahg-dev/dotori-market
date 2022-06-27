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
    private var productID: Int?
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
    
    // MARK: - binding
    func bindViewModel() {
        let input = ProductDetailSceneViewModel.Input(viewWillAppear: self.rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:))).map{ _ in self.productID!})
        
        let output = viewModel.transform(input: input)
        
        output.prdouctName
            .observe(on: MainScheduler.instance)
            .subscribe (onNext:{ [weak self] name in
                self?.configureNavigationTitle(with: name)
                self?.productNameLabel?.text = name })
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
            .subscribe (onNext:{ [weak self] discountedRate in
                if discountedRate == nil {
                    self?.productSellingPriceStackView?.spacing = .zero }
                self?.productDiscountRateLabel?.text = discountedRate })
            .disposed(by: disposeBag)
        
        output.productStock
            .observe(on: MainScheduler.instance)
            .subscribe { stock in
                self.productStockLabel?.text = stock }
            .disposed(by: disposeBag)
        
        output.productDescription
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] description in
                self?.productDescriptionTextView?.text = description }
            .disposed(by: disposeBag)
        
    }
    
    // MARK: - Configure UI
    private func configureStackViewLayout() {
        guard let productInfoStackView = self.productInfoStackView,
              let productStockLabel = self.productStockLabel else {
            return
        }
        productInfoStackView.setCustomSpacing(20, after: productStockLabel)
    }
    
    private func configureCollectionViewFlowLayout() {
        let cellWidth = self.view.frame.width
        self.flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        self.flowLayout.minimumLineSpacing = 0
        self.flowLayout.minimumInteritemSpacing = 0
        self.flowLayout.scrollDirection = .horizontal
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
        guard let scrollView = self.productImageCollectionView else {
            return
        }
        scrollView.delegate = self
    }
    
    // MARK: - API
    func setProduct(_ id: Int) {
        self.productID = id
    }
    
    // MARK: - Transition View
    @objc private func presentProductModificationView() {
        guard let productEditVC = self.storyboard?.instantiateViewController(withIdentifier: "ProductEidtViewController") as? ProductEidtViewController,
              let productID = self.productID else {
            return
        }
        productEditVC.setProduct(productID)
        productEditVC.modalPresentationStyle = .fullScreen
        self.present(productEditVC, animated: false)
    }
    
}

// MARK: - UIScrollViewDelegate
extension ProductDetailViewController: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let page = Int(targetContentOffset.pointee.x / self.view.frame.width)
        self.imagePageControl.currentPage = page
    }
}
