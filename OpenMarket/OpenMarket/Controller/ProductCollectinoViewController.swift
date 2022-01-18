//
//  ProductCollectinoViewController.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/12.
//

import UIKit

class ProductCollectinoViewController: UICollectionViewController {
    
    private var initialProductsListPage: ProductsListPage?
    private let flowLayout = UICollectionViewFlowLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGridLayout()
        
        let request = ProductsListPageRequest(pageNo: 1, itemsPerPage: 20)
        APIExecutor().execute(request) { (result: Result<ProductsListPage, Error>) in
            switch result {
            case .success(let productsListPage):
                self.initialProductsListPage = productsListPage
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                // Alert 넣기
                print("ProductsListPage 통신 중 에러 발생 : \(error)")
                return
            }
        }
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

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return initialProductsListPage?.pages.count ?? .zero
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProductCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? ProductCollectionViewCell else {
            return ProductCollectionViewCell()
        }
        
        guard let product = initialProductsListPage?.pages[indexPath.item] else {
            return cell
        }
        
        configureGridContent(of: cell, with: product)
        configureGridCellLayer(of: cell)
        
        return cell
    }
    
    private func configureGridContent(of cell: ProductCollectionViewCell, with product: Product) {
        DispatchQueue.main.async {
            cell.productThumbnail.image = self.getImage(from: product.thumbnail)
        }
        cell.productName.attributedText = product.attributedName
        cell.productPrice.attributedText = product.attributedPrice
        cell.productStock.attributedText = product.attributedStock
    }
    
    private func configureGridCellLayer(of cell: ProductCollectionViewCell) {
        cell.layer.borderColor = UIColor.systemGray.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 5
    }
    
    private func getImage(from url: String) -> UIImage? {
        guard let url = URL(string: url), let imageData = try? Data(contentsOf: url) else {
            let defaultImage = UIImage(systemName: "xmark.icloud")
            return defaultImage?.withTintColor(.systemGray, renderingMode: .alwaysOriginal)
        }
        return UIImage(data: imageData)
    }
}
