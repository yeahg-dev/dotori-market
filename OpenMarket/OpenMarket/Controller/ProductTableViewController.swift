//
//  ProductTableViewController.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/12.
//

import UIKit

class ProductTableViewController: UITableViewController {
    
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
        let cell = tableView.dequeueReusableCell(
            withClass: ProductTableViewCell.self,
            for: indexPath
        )
        
        guard let product = initialProductsListPage?.pages[indexPath.row] else {
            return cell
        }
        
        configureListContent(of: cell, with: product)
        
        return cell
    }
    
    private func configureListContent(of cell: ProductTableViewCell, with product: Product) {
        DispatchQueue.main.async {
            cell.productThumbnail.image = self.getImage(from: product.thumbnail)
        }
        cell.productName.attributedText = product.attributedName
        cell.productPrice.attributedText = product.attributedPrice
        cell.productStock.attributedText = product.attributedStock
    }
    
    private func getImage(from url: String) -> UIImage? {
        guard let url = URL(string: url), let imageData = try? Data(contentsOf: url) else {
            let defaultImage = UIImage(systemName: "xmark.icloud")
            return defaultImage?.withTintColor(.systemGray, renderingMode: .alwaysOriginal)
        }
        return UIImage(data: imageData)
    }
}

private extension UITableView {
    
    func dequeueReusableCell<T: UITableViewCell>(withClass name: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: String(describing: name), for: indexPath) as? T else {
            fatalError(
                "Couldn't find UITableViewCell for \(String(describing: name)), make sure the cell is registered with table view")
        }
        return cell
    }
}