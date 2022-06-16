//
//  ProductTableViewController.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/12.
//

import UIKit

final class ProductTableViewController: UITableViewController {
    
    private var currentPageNo: Int = 1
    private var hasNextPage: Bool = false
    private var products: [Product] = []
    private let loadingIndicator = UIActivityIndicatorView()
    private let apiService = MarketAPIService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startloadingIndicator()
        downloadProductsListPage(number: currentPageNo)
        configureRefreshControl()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withClass: ProductTableViewCell.self,
            for: indexPath
        )
        
        guard let product = products[safe: indexPath.row] else {
            return cell
        }
        
        cell.configureTableContent(with: product)
        
        return cell
    }
    
    override func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        let paginationBuffer = 3
        guard indexPath.row == products.count - paginationBuffer,
              hasNextPage == true else { return }
        
        downloadProductsListPage(number: currentPageNo + 1)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let productID = products[indexPath.row].id
        
        guard let productDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "ProductDetailViewController") as? ProductDetailViewController else {
            return
        }
        productDetailVC.setProduct(productID)
        self.navigationController?.pushViewController(productDetailVC, animated: true)
    }
    
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
