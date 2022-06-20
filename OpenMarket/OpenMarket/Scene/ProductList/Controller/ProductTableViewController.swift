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
    
    private var currentPageNo: Int = 1
    private var hasNextPage: Bool = false
    private var products: [Product] = []
    private let loadingIndicator = UIActivityIndicatorView()
    private let apiService = MarketAPIService()
    private let disposeBag = DisposeBag()
    
    private let viewModel = ProductTableViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startloadingIndicator()
        configureRefreshControl()
        self.tableView.dataSource = nil
        bindViewModel()
    }
    
    func bindViewModel() {
        let input = ProductTableViewModel.Input(
            viewWillAppear: self.rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:))).map{_ in},
            willDisplayCell: self.tableView.rx.willDisplayCell.map({ $0.indexPath.row}),
            willRefrsesh: self.tableView.refreshControl!.rx.controlEvent(.valueChanged).asObservable())
        let output = self.viewModel.transform(input: input)
        
        output.products
            .observe(on: MainScheduler.instance)
            .do(onNext: { _ in
                guard self.loadingIndicator.isAnimating else { return }
                self.loadingIndicator.stopAnimating()
            })
            .bind(to: tableView.rx.items(cellIdentifier: "ProductTableViewCell", cellType: ProductTableViewCell.self)) { (row, element, cell) in
                cell.fill(with: element)}
            .disposed(by: disposeBag)
        
        output.endRefresh
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.refreshControl?.endRefreshing()})
            .disposed(by: disposeBag)
        
        // TODO: - 통신 중 에러 처리
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let productID = products[indexPath.row].id
//
//        guard let productDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "ProductDetailViewController") as? ProductDetailViewController else {
//            return
//        }
//        productDetailVC.setProduct(productID)
//        self.navigationController?.pushViewController(productDetailVC, animated: true)
//    }
    
    // MARK: - Custom function
    
    private func startloadingIndicator() {
        view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            loadingIndicator.centerYAnchor.constraint(
                equalTo: safeArea.centerYAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor)
        ])
        loadingIndicator.startAnimating()
    }
    
    private func configureRefreshControl() {
        self.tableView.refreshControl = UIRefreshControl()
    }

}

// MARK: - RefreshDelegate

extension ProductTableViewController: RefreshDelegate {
    
    func refresh() {
        
    }
}
