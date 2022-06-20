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
    private let flowLayout = UICollectionViewFlowLayout()
    private let loadingIndicator = UIActivityIndicatorView()
    
    // MARK: - Property
    private let viewModel = ProductListViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK:- View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadingIndicator.startAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGridLayout()
        configureLoadingIndicator()
        configureRefreshControl()
        self.collectionView.dataSource = nil
        self.bindViewModel()
    }
    
    // MARK: - binding
    private func bindViewModel() {
        let input = ProductListViewModel.Input(
            viewWillAppear: self.rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:))).map{_ in},
            willDisplayCell: self.collectionView.rx.willDisplayCell.map({ cell, index in index.row }),
            willRefrsesh: self.collectionView.refreshControl!.rx.controlEvent(.valueChanged).asObservable(),
            didSelectRowAt: self.collectionView.rx.itemSelected.map{ $0.row })
        let output = self.viewModel.transform(input: input)
        
        output.products
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                guard ((self?.loadingIndicator.isAnimating) != nil) else { return }
                self?.loadingIndicator.stopAnimating()
            }, onError: { _ in
                self.presentNetworkErrorAlert()})
            .retry(when:{ _ in self.collectionView.refreshControl!.rx.controlEvent(.valueChanged).asObservable()})
            .bind(to: collectionView.rx.items(cellIdentifier: "ProductCollectionViewCell", cellType: ProductCollectionViewCell.self)) { (row, element, cell) in
                cell.fill(with: element)}
            .disposed(by: disposeBag)
        
        output.endRefresh
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.collectionView.refreshControl?.endRefreshing()})
            .disposed(by: disposeBag)
        
        output.pushProductDetailView
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] productID in
                self?.pushProductDetailView(of: productID)
            }
            .disposed(by: disposeBag)
    }
    // MARK: - configure UI
    private func configureGridLayout() {
        collectionView.collectionViewLayout = flowLayout
        let cellWidth = view.bounds.size.width / 2 - 10
        // FIXME: cell 의 height 값에 intrinsic size 를 부여하는 방법을 찾아서 고쳐야 함!
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth * 1.55)
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: .zero, right: 5)
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
        collectionView.refreshControl = UIRefreshControl()

    }

    // MARK: - Method
    private func pushProductDetailView(of productID: Int) {
        guard let productDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "ProductDetailViewController") as? ProductDetailViewController else {
            return
        }
        productDetailVC.setProduct(productID)
        self.navigationController?.pushViewController(productDetailVC, animated: true)
    }

    private func presentNetworkErrorAlert() {
        let alert = UIAlertController(title: "다시 시도해주세요😢", message: "통신 에러가 발생했어요", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default)
        alert.addAction(okAction)
        self.present(alert, animated: false)
    }
}
