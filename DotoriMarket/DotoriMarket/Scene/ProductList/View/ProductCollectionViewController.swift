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
    private var coordinator: AllProductListCoordinator?
    
    private let viewModel = ProductListSceneViewModel(usecase: AllProductGridUsecase())
    private let disposeBag = DisposeBag()
    
    // MARK: - Load from Storyboard
    
    static func make(coordinator: AllProductListCoordinator) -> ProductCollectionViewController {
        let productListVC = UIStoryboard.initiateViewController(ProductCollectionViewController.self)
        productListVC.coordinator = coordinator
        return productListVC
    }
    
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
        guard let refreshControl = self.collectionView.refreshControl else {
            return
        }
        
        let input = ProductListSceneViewModel.Input(
            viewWillAppear: self.rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:))).map{ _ in },
            willDisplayCellAtIndex: self.collectionView.rx.willDisplayCell.map({ cell, index in index.row }),
            listViewDidStartRefresh: refreshControl.rx.controlEvent(.valueChanged).asObservable(),
            cellDidSelectedAt: self.collectionView.rx.itemSelected.map{ $0.row })
        let output = self.viewModel.transform(input: input)
        
        output.navigationBarComponent
            .drive(onNext: {[weak self] component in
                self?.confiureNavigationItem(with: component) })
            .disposed(by: disposeBag)
        
        output.willStartLoadingIndicator
            .drive(onNext:{ [weak self] _ in
                self?.loadingIndicator.startAnimating() })
            .disposed(by: disposeBag)
        
        output.willEndLoadingIndicator
            .drive(onNext:{ [weak self] _ in
                self?.loadingIndicator.stopAnimating() })
            .disposed(by: disposeBag)
        
        output.products
            .drive(collectionView.rx.items(cellIdentifier: "ProductCollectionViewCell",
                                              cellType: ProductCollectionViewCell.self))
            { (_, element, cell) in
                cell.fillContent(of: element) }
            .disposed(by: disposeBag)
        
        output.networkErrorAlert
            .drive{ [weak self] viewModel in
                self?.presentNetworkErrorAlert(viewModel: viewModel) }
            .disposed(by: disposeBag)
        
        output.listViewWillEndRefresh
            .drive(onNext: { [weak self] _ in
                self?.collectionView?.refreshControl?.endRefreshing() })
            .disposed(by: disposeBag)
        
        output.pushProductDetailView
            .drive(onNext:{ [weak self] productID in
                self?.coordinator?.cellDidTapped(of: productID) })
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
    
    private func confiureNavigationItem(with navigationBarComponent: NavigationBarComponent) {
        let toggleViewModeButton = UIBarButtonItem(
            image: UIImage(systemName: navigationBarComponent.rightBarButtonImageSystemName),
            style: .plain,
            target: self,
            action: #selector(toggleViewMode))
        self.navigationItem.setRightBarButton(toggleViewModeButton, animated: false)
        
        self.navigationItem.title = navigationBarComponent.title
    }
    
    @objc func toggleViewMode() {
        coordinator?.rightNavigationItemDidTapped(from: self)
    }

    // MARK: - Present Alert
    
    private func presentNetworkErrorAlert(viewModel: AlertViewModel) {
        let alert = UIAlertController(title: viewModel.title, message: viewModel.message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: viewModel.actionTitle, style: .default)
        alert.addAction(okAction)
        self.present(alert, animated: false)
    }
}
