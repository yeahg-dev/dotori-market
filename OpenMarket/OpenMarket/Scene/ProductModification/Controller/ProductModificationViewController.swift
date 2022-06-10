//
//  ProductModificationViewController.swift
//  OpenMarket
//
//  Created by 1 on 2022/06/09.
//

import UIKit

final class ProductModificationViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var productImageCollectionView: UICollectionView?
    @IBOutlet weak var productNameLabel: UITextField?
    @IBOutlet weak var prdouctPriceLabel: UITextField?
    @IBOutlet weak var productCurrencySegmentedControl: UISegmentedControl?
    @IBOutlet weak var productDisconutPriceLabel: UITextField?
    @IBOutlet weak var productStockLabel: UITextField?
    @IBOutlet weak var productDescriptionTextView: UITextView?
    
    // MARK: - Property
    private let apiService = APIExecutor()
    private var productID: Int?
    private var productDetail: ProductDetail?
    private var cells: [CellType] = [.imagePickerCell]
    private var productImages: [UIImage] = []
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionViewLayout()
        self.downloadProductDetail(of: productID)
    }
    
    // MARK: - Layout
    private func configureCollectionViewLayout() {
        self.productImageCollectionView?.showsVerticalScrollIndicator = false
        self.productImageCollectionView?.showsHorizontalScrollIndicator = false
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        let cellWidth = view.bounds.size.width / 4
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        flowLayout.minimumLineSpacing = 10
        flowLayout.sectionInset = UIEdgeInsets(top: .zero, left: 10, bottom: .zero, right: 10)
        self.productImageCollectionView?.collectionViewLayout = flowLayout
    }
    
    // MARK: - IBAction
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    // MARK: -Method
    func setProduct(_ productID: Int) {
        self.productID = productID
    }
    
    private func downloadProductDetail(of prodcutID: Int?) {
        guard let id = prodcutID else { return }
        
        let request = ProductDetailRequest(productID: id)
        apiService.execute(request) { [weak self] (result: Result<ProductDetail, Error>) in
            switch result {
            case .success(let product):
                self?.productDetail = product
                for image in product.images {
                    self?.cells.append(.productImageCell)
//                    if let url = URL(string: image.thumbnailURL) {
//                        self?.downloadAndappendProductImage(of: url)
//                    }
                }
                DispatchQueue.main.async {
                    self?.fillUI(wtih: product)
                    self?.productImageCollectionView?.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func fillUI(wtih product: ProductDetail) {
        self.productNameLabel?.text = product.name
        self.prdouctPriceLabel?.text = product.price.formatted()
        self.productDisconutPriceLabel?.text  = product.discountedPrice.formatted()
        self.productStockLabel?.text = product.stock.formatted()
        self.productDescriptionTextView?.text = product.description
        let currency = product.currency
        switch currency {
        case .krw:
            self.productCurrencySegmentedControl?.selectedSegmentIndex = 0
        case .usd:
            self.productCurrencySegmentedControl?.selectedSegmentIndex = 1
        }
    }
    
    private func downloadAndappendProductImage(of url: URL) {
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let _ = error {
                DispatchQueue.main.async {
                    if let invalidImage = UIImage(systemName: "xmark.icloud.fill") {
                        self?.productImages.append(invalidImage)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    guard let imageData = data,
                          let uiimage = UIImage(data: imageData) else { return }
                    self?.productImages.append(uiimage)
                }
            }
        }
        task.resume()
    }

}

extension ProductModificationViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellType = cells[safe: indexPath.item]
        
        switch cellType {
        case .imagePickerCell:
            let cell = collectionView.dequeueReusableCell(
                withClass: ImagePickerCollectionViewCell.self,
                for: indexPath
            )
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(
                withClass: ProductImageCollectionViewCell.self,
                for: indexPath
            )
            let targetImage = productImages[safe: indexPath.item - 1]
        
            // URL로 다운로드 받도록 수정해야함
            // cell을 채우는 메서드의 매개변수 타입이 다름 URL vs UIImage
            // 이미지 피커 컨트롤러로 대표사진이 수정되었을 때 reloadRow를 호출해야함.
            let imageURLStirng = productDetail?.images[indexPath.item - 1].thumbnailURL ?? ""
            let imageURL = URL(string: imageURLStirng)
            if indexPath.item == 1 {
                cell.update(image: targetImage, url: imageURL!, isRepresentaion: true)
            } else {
                cell.update(image: nil, url: imageURL!, isRepresentaion: false)
            }
            return cell
        }
    }

}
