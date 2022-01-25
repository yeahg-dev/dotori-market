//
//  ProductRegistrationViewController.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/21.
//

import UIKit

final class ProductRegistrationViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var navigationBar: UINavigationBar?
    @IBOutlet private weak var productImageCollectionView: UICollectionView?
    @IBOutlet private weak var nameTextField: UITextField?
    @IBOutlet private weak var priceTextField: UITextField?
    @IBOutlet private weak var currencySegmentedControl: UISegmentedControl?
    @IBOutlet private weak var discountedPriceTextField: UITextField?
    @IBOutlet private weak var stockTextField: UITextField?
    @IBOutlet private weak var descriptionsTextView: UITextView?
    
    // MARK: - Properties
    
    private let imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        return imagePicker
    }()
    private var productImages: [UIImage] = []
    private let flowLayout = UICollectionViewFlowLayout()
    
    // MARK: - Methods
    
    @IBAction private func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction private func doneButtonTapped(_ sender: UIBarButtonItem) {
        guard let name = nameTextField?.text else { return }
        guard let price = priceTextField?.text else { return }
        var currency: Currency
        if currencySegmentedControl?.selectedSegmentIndex == .zero {
            currency = .krw
        } else {
            currency = .usd
        }
        let discountedPrice = discountedPriceTextField?.text ?? "0"
        let stock = stockTextField?.text ?? "0"
        guard let descriptions = descriptionsTextView?.text else { return }
        
        let newProduct = NewProductInfo(name: name, descriptions: descriptions, price: (price as NSString).doubleValue, currency: currency, discountedPrice: (discountedPrice as NSString).doubleValue, stock: (stock as NSString).integerValue, secret: "aFJkk2KmB53A*6LT")
        
        var imageFileNumber = 1
        var newProductImages: [ImageFile] = []
        productImages.forEach { image in
            guard let data = image.jpegData(compressionQuality: 0) else { return }
            let imageFile = ImageFile(fileName: "\(name)-\(imageFileNumber)", data: data, type: .jpeg)
            imageFileNumber += 1
            newProductImages.append(imageFile)
        }
        
        let request = ProductRegistrationRequest(identifier: "c4dedd67-71fc-11ec-abfa-fd97ecfece87", params: newProduct, images: newProductImages)
        
        APIExecutor().execute(request) { (result: Result<ProductDetail, Error>) in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.showAlert(title: "상품이 성공적으로 등록됐습니다", message: "아싸") { _ in
                        self.dismiss(animated: true) {
                            NotificationCenter.default.post(name: .newProductRegistered, object: nil)
                        }
                    }
                }
            case .failure(let error):
                print("에러가 발생했습니다! : \(error)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        productImageCollectionView?.delegate = self
        productImageCollectionView?.dataSource = self
        configureNavigationBar()
        configureFlowLayout()
        addKeyboardNotificationObserver()
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
        flowLayout.sectionInset = UIEdgeInsets(top: .zero, left: 10, bottom: .zero, right: 10)
    }
    
    private func addKeyboardNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

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
            showAlert(title: "Too Much Images", message: "최대 \(maximumImageCount)장까지만 첨부할 수 있어요", handler: nil)
            return
        }
        if indexPath.item == .zero {
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension ProductRegistrationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let possibleImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            productImages.append(possibleImage) // 수정된 이미지가 있을 경우
        } else if let possibleImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            productImages.append(possibleImage) // 원본으로 그냥 내보내는 경우
        }
        productImageCollectionView?.reloadData()
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate

extension ProductRegistrationViewController: UITextFieldDelegate {
    
    @objc private func keyboardWillShow(_ sender: Notification) {
        if let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.view.frame.origin.y = -keyboardHeight
        }
    }
    
    @objc private func keyboardWillHide(_ sender: Notification) {
        self.view.frame.origin.y = .zero
    }
}
