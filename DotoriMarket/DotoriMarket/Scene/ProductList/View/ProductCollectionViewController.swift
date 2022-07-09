//
//  ProductCollectionViewController.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/12.
//

import UIKit

import RxSwift
import RxCocoa

final class ProductCollectionViewController: UICollectionViewController {
    
    // MARK: - UI Property
    
    private let loadingIndicator = UIActivityIndicatorView()
    
    // MARK: - Property
    
    private let viewModel = ProductListSceneViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - View Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpCollectionView()
        self.configureLoadingIndicator()
        self.configureRefreshControl()
        self.bindViewModel()
    }
    
    // MARK: - binding
    
    private func bindViewModel() {
        let input = ProductListSceneViewModel.Input(
            viewWillAppear: self.rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:))).map{ _ in },
            willDisplayCellAtIndex: self.collectionView.rx.willDisplayCell.map({ cell, index in index.row }),
            listViewDidStartRefresh: self.collectionView.refreshControl!.rx.controlEvent(.valueChanged).asObservable(),
            cellDidSelectedAt: self.collectionView.rx.itemSelected.map{ $0.row })
        let output = self.viewModel.transform(input: input)
        
        output.willStartLoadingIndicator
            .observe(on: MainScheduler.instance)
            .subscribe{ [weak self] _ in
                self?.loadingIndicator.startAnimating() }
            .disposed(by: disposeBag)
        
        output.willEndLoadingIndicator
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] _ in
                self?.loadingIndicator.stopAnimating() }
            .disposed(by: disposeBag)
        
        output.products
            .observe(on: MainScheduler.instance)
            .do(onError: { _ in
                self.presentNetworkErrorAlert() })
            .retry(when: { _ in self.collectionView.refreshControl!.rx.controlEvent(.valueChanged).asObservable() })
            .bind(to: collectionView.rx.items(cellIdentifier: "ProductCollectionViewCell",
                                              cellType: ProductCollectionViewCell.self))
            { (row, element, cell) in
                cell.fillContent(of: element) }
            .disposed(by: disposeBag)
        
        output.listViewWillEndRefresh
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.collectionView.refreshControl?.endRefreshing() })
            .disposed(by: disposeBag)
        
        output.pushProductDetailView
            .subscribe{ [weak self] productID in
                self?.pushProductDetailView(of: productID) }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Configure UI
    
    private func setUpCollectionView() {
        self.collectionView.collectionViewLayout = self.configureGridLayout()
        self.collectionView.dataSource = nil
    }
    
    private func configureGridLayout() -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        let cellWidth = view.bounds.size.width / 2 - 10
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth * 1.55)
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: .zero, right: 5)
        return flowLayout
    }
    
    private func configureLoadingIndicator() {
        view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate(
            [loadingIndicator.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor)]
        )
    }

    private func configureRefreshControl() {
        self.collectionView.refreshControl = UIRefreshControl()
    }

    // MARK: - Transition View
    
    private func pushProductDetailView(of productID: Int) {
        guard let productDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "ProductDetailViewController") as? ProductDetailViewController else {
            return
        }
        productDetailVC.setProduct(productID)
        self.navigationController?.pushViewController(productDetailVC, animated: true)
    }

    // MARK: - Present Alert
    
    private func presentNetworkErrorAlert() {
        let alert = UIAlertController(title: "다시 시도해주세요😢", message: "통신 에러가 발생했어요", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default)
        alert.addAction(okAction)
        self.present(alert, animated: false)
    }
}
