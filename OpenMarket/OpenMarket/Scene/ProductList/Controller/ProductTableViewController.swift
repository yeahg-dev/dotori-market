//
//  ProductTableViewController.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/12.
//

import UIKit
import RxSwift
import RxCocoa

final class ProductTableViewController: UITableViewController {
    
    // MARK: - UI Property
    private let loadingIndicator = UIActivityIndicatorView()
    
    // MARK: - Property
    private let disposeBag = DisposeBag()
    private let viewModel = ProductTableViewModel()
    
    // MARK: - View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadingIndicator.startAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLoadingIndicator()
        configureRefreshControl()
        self.tableView.dataSource = nil
        bindViewModel()
    }
    
    // MARK: - binding
    private func bindViewModel() {
        let input = ProductTableViewModel.Input(
            viewWillAppear: self.rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:))).map{_ in},
            willDisplayCell: self.tableView.rx.willDisplayCell.map({ $0.indexPath.row}),
            willRefrsesh: self.tableView.refreshControl!.rx.controlEvent(.valueChanged).asObservable(),
            didSelectRowAt: self.tableView.rx.itemSelected.map({ $0.row}))
        let output = self.viewModel.transform(input: input)
        
        output.products
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                guard ((self?.loadingIndicator.isAnimating) != nil) else { return }
                self?.loadingIndicator.stopAnimating()
            })
            .bind(to: tableView.rx.items(cellIdentifier: "ProductTableViewCell", cellType: ProductTableViewCell.self)) { (row, element, cell) in
                cell.fill(with: element)}
            .disposed(by: disposeBag)
        
        output.endRefresh
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.refreshControl?.endRefreshing()})
            .disposed(by: disposeBag)
        
        output.pushProductDetailView
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] productID in
                self?.pushProductDetailView(of: productID)
            }
            .disposed(by: disposeBag)

        // TODO: - 통신 중 에러 처리
    }
    
    // MARK: - Method
    private func configureLoadingIndicator() {
        view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            loadingIndicator.centerYAnchor.constraint(
                equalTo: safeArea.centerYAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor)
        ])
    }
    
    private func configureRefreshControl() {
        self.tableView.refreshControl = UIRefreshControl()
    }
    
    private func pushProductDetailView(of productID: Int) {
        guard let productDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "ProductDetailViewController") as? ProductDetailViewController else {
            return
        }
        productDetailVC.setProduct(productID)
        self.navigationController?.pushViewController(productDetailVC, animated: true)
    }

}
