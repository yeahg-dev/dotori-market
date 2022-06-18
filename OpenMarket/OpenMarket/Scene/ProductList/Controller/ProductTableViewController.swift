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
//        startloadingIndicator()
//        configureRefreshControl()
        self.tableView.dataSource = nil
        bindViewModel()
    }
    
    func bindViewModel() {
        let input = ProductTableViewModel.Input(viewWillAppear: self.rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:))).map{_ in})
        let output = self.viewModel.transform(input: input)
        
        output.products
            .bind(to: tableView.rx.items) { (tableView, row, element) in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell") as? ProductTableViewCell else{
                    return ProductTableViewCell()
                }
                cell.fill(with: element)
                return cell
            }
            .disposed(by: disposeBag)
    }
    
//    override func tableView(
//        _ tableView: UITableView,
//        willDisplay cell: UITableViewCell,
//        forRowAt indexPath: IndexPath
//    ) {
//        let paginationBuffer = 3
//        guard indexPath.row == products.count - paginationBuffer,
//              hasNextPage == true else { return }
//
//        downloadProductsListPage(number: currentPageNo + 1)
//    }
//
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
    
    private func downloadProductsListPage(number: Int) {
        let request = ProductsListPageRequest(pageNo: number, itemsPerPage: 20)
        apiService.request(request) { [weak self] (result: Result<ProductsListPage, Error>) in
            switch result {
            case .success(let productsListPage):
                self?.currentPageNo = productsListPage.pageNo
                self?.hasNextPage = productsListPage.hasNext
                self?.products.append(contentsOf: productsListPage.pages)
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.loadingIndicator.stopAnimating()
                }
            case .failure(let error):
                // Alert 넣기
                print("ProductsListPage 통신 중 에러 발생 : \(error)")
                return
            }
        }
    }
    
    private func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(
            self,
            action: #selector(handleRefreshControl),
            for: .valueChanged
        )
    }
    
    @objc private func handleRefreshControl() {
        resetProductListPageInfo()
        let request = ProductsListPageRequest(pageNo: 1, itemsPerPage: 20)
        apiService.request(request) { [weak self] (result: Result<ProductsListPage, Error>) in
            switch result {
            case .success(let productsListPage):
                self?.currentPageNo = productsListPage.pageNo
                self?.hasNextPage = productsListPage.hasNext
                self?.products.append(contentsOf: productsListPage.pages)
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    if self?.refreshControl?.isRefreshing == false {
                        self?.scrollToTop(animated: false)
                    }
                    self?.refreshControl?.endRefreshing()
                }
            case .failure(let error):
                // Alert 넣기
                print("ProductsListPage 통신 중 에러 발생 : \(error)")
                return
            }
        }
    }
    
    private func resetProductListPageInfo() {
        currentPageNo = 1
        hasNextPage = false
        products.removeAll()
    }
}

// MARK: - RefreshDelegate

extension ProductTableViewController: RefreshDelegate {
    
    func refresh() {
        handleRefreshControl()
    }
}
