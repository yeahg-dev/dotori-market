//
//  ProductRegistrationViewController.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/21.
//

import UIKit

final class ProductRegistrationViewController: UIViewController {
    
    private let imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        return imagePicker
    }()
    private var productImages: [UIImage] = []
    private let flowLayout = UICollectionViewFlowLayout()
    
    @IBOutlet private weak var navigationBar: UINavigationBar?
    @IBOutlet private weak var productImageCollectionView: UICollectionView?
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        productImageCollectionView?.delegate = self
        productImageCollectionView?.dataSource = self
        configureNavigationBar()
        configureFlowLayout()
    }
    
    private func configureNavigationBar() {
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithTransparentBackground()
        navigationBar?.standardAppearance = navigationAppearance
    }
    
    private func configureFlowLayout() {
        productImageCollectionView?.collectionViewLayout = flowLayout
        flowLayout.scrollDirection = .horizontal
        productImageCollectionView?.showsVerticalScrollIndicator = false
        productImageCollectionView?.showsHorizontalScrollIndicator = false
        
        let cellWidth = view.bounds.size.width / 4
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        flowLayout.minimumLineSpacing = 10
        flowLayout.sectionInset = UIEdgeInsets(top: .zero, left: 20, bottom: .zero, right: 20)
    }
}

extension ProductRegistrationViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let imagePickerCell = 1
        return imagePickerCell + productImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let productImageCollectionView = productImageCollectionView else {
            return UICollectionViewCell()
        }
        
        if indexPath.item == .zero {
            let cell = productImageCollectionView.dequeueReusableCell(withClass: ImagePickerCollectionViewCell.self, for: indexPath)
            cell.updateAddedImageCountLabel(images: productImages)
            return cell
        } else {
            let cell = productImageCollectionView.dequeueReusableCell(withClass: ProductImageCollectionViewCell.self, for: indexPath)
            let targetImage = productImages[safe: indexPath.item - 1]
            cell.updateProductImageView(image: targetImage)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let maximumImageCount = 5
        guard productImages.count < maximumImageCount else {
            showAlert(title: "Too Much Images", message: "최대 \(maximumImageCount)장까지만 첨부할 수 있어요")
            return
        }
        if indexPath.item == .zero {
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        }
    }
}

extension ProductRegistrationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let possibleImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            productImages.append(possibleImage) // 수정된 이미지가 있을 경우
        } else if let possibleImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            productImages.append(possibleImage) // 원본으로 그냥 내보내는 경우
        }
        productImageCollectionView?.reloadData()
        imagePicker.dismiss(animated: true, completion: nil) // 이미지 피커 내려가!
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
