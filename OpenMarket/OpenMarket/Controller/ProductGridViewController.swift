//
//  ProductGridViewController.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/12.
//

import UIKit

class ProductGridViewController: UICollectionViewController {
    
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
        let cellWidth = view.bounds.size.width / 2 - 30
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth * 1.5)
        flowLayout.minimumLineSpacing = .zero
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
            withReuseIdentifier: ProductGridViewCell.reuseIdentifier,
            for: indexPath
        ) as? ProductGridViewCell else {
            return ProductGridViewCell()
        }
        
        guard let product = initialProductsListPage?.pages[indexPath.item] else {
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
            return defaultImage?.withTintColor(.systemGray)
        }
        return UIImage(data: imageData)
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
