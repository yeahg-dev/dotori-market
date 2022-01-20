//
//  ProductCollectinoViewController.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/12.
//

import UIKit

final class ProductCollectinoViewController: UICollectionViewController {
    
    private var currentPageNo: Int = .zero
    private var hasNextPage: Bool = false
    private var products: [Product] = []
    private let flowLayout = UICollectionViewFlowLayout()
    private let loadingIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startloadingIndicator()
        configureGridLayout()
        downloadProductsListPage(number: 1)
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return products.count
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withClass: ProductCollectionViewCell.self,
            for: indexPath
        )
        
        guard let product = products[safe: indexPath.item] else {
            return cell
        }
        
        cell.configureCollectionContent(with: product)
        
        return cell
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        let paginationBuffer = 4
        guard indexPath.item >= products.count - paginationBuffer,
              hasNextPage == true else { return }

        downloadProductsListPage(number: currentPageNo + 1)
    }
    
    // MARK: - Custom function
    
    private func startloadingIndicator() {
        view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            loadingIndicator.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor), loadingIndicator.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor)
        ])
        loadingIndicator.startAnimating()
    }
    
    private func configureGridLayout() {
        collectionView.collectionViewLayout = flowLayout
        let cellWidth = view.bounds.size.width / 2 - 10
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth * 1.5)
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: .zero, right: 5)
    }
    
    private func downloadProductsListPage(number: Int) {
        let request = ProductsListPageRequest(pageNo: number, itemsPerPage: 20)
        APIExecutor().execute(request) { (result: Result<ProductsListPage, Error>) in
            switch result {
            case .success(let productsListPage):
                self.currentPageNo = productsListPage.pageNo
                self.hasNextPage = productsListPage.hasNext
                self.products.append(contentsOf: productsListPage.pages)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.loadingIndicator.stopAnimating()
                }
            case .failure(let error):
                // Alert 넣기
                print("ProductsListPage 통신 중 에러 발생 : \(error)")
                return
            }
        }
    }
}
