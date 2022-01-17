//
//  ProductListViewController.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/12.
//

import UIKit

class ProductListViewController: UITableViewController {
    
    private var initialProductsListPage: ProductsListPage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = ProductsListPageRequest(pageNo: 1, itemsPerPage: 20)
        APIExecutor().execute(request) { (result: Result<ProductsListPage, Error>) in
            switch result {
            case .success(let productsListPage):
                self.initialProductsListPage = productsListPage
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                // Alert 넣기
                print("ProductsListPage 통신 중 에러 발생 : \(error)")
                return
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return initialProductsListPage?.pages.count ?? .zero
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ProductListViewCell.reuseIdentifier,
            for: indexPath
        ) as? ProductListViewCell else {
            return ProductListViewCell()
        }
        
        guard let product = initialProductsListPage?.pages[indexPath.row] else {
            return cell
        }
    
        cell.productThumbnail.image = getImage(from: product.thumbnail)
        cell.productName.attributedText = product.attributedName
        cell.productPrice.attributedText = product.attributedPrice
        cell.productStock.attributedText = product.attributedStock

        return cell
    }
    
    private func getImage(from url: String) -> UIImage? {
        guard let url = URL(string: url), let imageData = try? Data(contentsOf: url) else {
            let defaultImage = UIImage(systemName: "xmark.icloud")
            return defaultImage?.withTintColor(.systemGray, renderingMode: .alwaysOriginal)
        }
        return UIImage(data: imageData)
    }
}
