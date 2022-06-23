//
//  ProductRegistrationViewController.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/21.
//

import UIKit
import RxSwift
import RxCocoa

final class ProductRegistrationViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var navigationBar: UINavigationBar?
    @IBOutlet private weak var scrollView: UIScrollView?
    @IBOutlet private weak var productImageCollectionView: UICollectionView?
    @IBOutlet private weak var nameTextField: UITextField?
    @IBOutlet private weak var priceTextField: UITextField?
    @IBOutlet private weak var currencySegmentedControl: UISegmentedControl?
    @IBOutlet private weak var discountedPriceTextField: UITextField?
    @IBOutlet private weak var stockTextField: UITextField?
    @IBOutlet private weak var descriptionsTextView: UITextView?
    
    // MARK: - UI Property
    weak var tableViewRefreshDelegate: RefreshDelegate?
    weak var collectionViewRefreshDelegate: RefreshDelegate?
    private let imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        return imagePicker
    }()
    private var productImages: [UIImage] = []
    private let flowLayout = UICollectionViewFlowLayout()
    private var textViewPlaceHolder: String?
    
    // MARK: - Properties
    private let viewModel = ProductRegisterationViewModel()
    private let disposeBag = DisposeBag()
    private let pickerImage = PublishSubject<UIImage>()
    private let secret = PublishSubject<String>()
    private var cells: [CellType] = [.imagePickerCell]
 
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureDelegate()
        self.configureNavigationBar()
        self.configureFlowLayout()
        self.bindViewModel()
    }
    
    // MARK: - Configure UI
    private func configureDelegate() {
        self.nameTextField?.delegate = self
        self.descriptionsTextView?.delegate = self
        self.imagePicker.delegate = self
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

    // MARK: - binding
    private func bindViewModel() {
        guard let doneButton = self.navigationBar?.items?[0].rightBarButtonItem as? UIBarButtonItem else { return }
        
        let input = ProductRegisterationViewModel.Input(
            viewWillAppear: self.rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:))).map{_ in},
            itemSelected: self.productImageCollectionView!.rx.itemSelected.map({ index in index.row }),
            didSelectImage: self.pickerImage,
            productTitle: self.nameTextField!.rx.text.asObservable(),
            productPrice: self.priceTextField!.rx.text.asObservable(),
            prdouctDiscountedPrice: self.discountedPriceTextField!.rx.text.asObservable(),
            productStock: self.stockTextField!.rx.text.asObservable(),
            productDescriptionText: self.descriptionsTextView!.rx.text.asObservable(),
            requestRegisteration: doneButton.rx.tap.asObservable(),
            didRequestWithSecret: self.secret.asObservable())
        
        let output = self.viewModel.transform(input: input)
        
        let productImages = output.productImages.share(replay: 1)
        
        output.presentImagePicker
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let imagePickerController = self?.imagePicker else { return }
                self?.present(imagePickerController, animated: false) })
            .disposed(by: disposeBag)
        
        output.textViewPlaceholder
            .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] (placeholder: String) in
                self?.textViewPlaceHolder = placeholder
                self?.descriptionsTextView?.text = placeholder
                self?.descriptionsTextView?.font = .preferredFont(forTextStyle: .footnote)
                self?.descriptionsTextView?.textColor = .systemGray2 })
            .disposed(by: disposeBag)
        
        productImages
            .observe(on: MainScheduler.instance)
            .bind(to: productImageCollectionView!.rx.items) { [weak self] (tableView, row, element) in
                let indexPath = IndexPath(row: row, section: 0)
                let cellType = element.0
                
                switch cellType {
                case .imagePickerCell:
                    guard let cell = self?.productImageCollectionView?.dequeueReusableCell(
                        withClass: ImagePickerCollectionViewCell.self,
                        for: indexPath
                    ) else { return ImagePickerCollectionViewCell() }
                    cell.updateAddedImageCountLabel(productImageCount: (self?.cells.count ?? 1) - 1)
                    return cell
                default:
                    guard let cell = self?.productImageCollectionView?.dequeueReusableCell(withReuseIdentifier: "ProductImageCollectionViewCell", for: indexPath) as? ProductImageCollectionViewCell else {
                        return ProductImageCollectionViewCell()
                    }
                    if row == 1 {
                        cell.updateProductImageView(image: element.1, isRepresentaion: true)
                    } else {
                        cell.updateProductImageView(image: element.1, isRepresentaion: false)
                    }
                    return cell
                }}
                .disposed(by: disposeBag)
        
        output.excessImageAlert
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] excessImageAlert in
                self?.presentAlert(excessImageAlert: excessImageAlert) }
            .disposed(by: disposeBag)
        
        output.inputValidationAlert
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] description in
                let alert = UIAlertController(title: description, message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                    alert.dismiss(animated: false)
                }
                alert.addAction(okAction)
                self?.present(alert, animated: false)
            })
            .disposed(by: disposeBag)
        
        output.requireSecret
            .observe(on: MainScheduler.instance)
            .subscribe { _ in
                let alert = UIAlertController(title: "비밀번호를 입력해주세요", message: nil, preferredStyle: .alert)
                let sendAction = UIAlertAction(title: "등록", style: .default) { _ in
                    guard let secret = alert.textFields?[0].text else { return }
                    self.secret.onNext(secret)
                    alert.dismiss(animated: false)
                }
                alert.addAction(sendAction)
                alert.addTextField()
                self.present(alert, animated: false)
            }
            .disposed(by: disposeBag)

    }

    // MARK: - IBaction Method
    @IBAction private func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction private func doneButtonTapped(_ sender: UIBarButtonItem) {
//        handleProductRegistrationRequest()
    }

    // MARK: - Method
    private func handleProductRegistrationRequest() {
        guard let newProduct = createNewProductInfo() else { return }
        guard let newProductImages = createImageFiles(newProductName: newProduct.name) else {
            return
        }
        
        let request = ProductRegistrationRequest(
            identifier: "c4dedd67-71fc-11ec-abfa-fd97ecfece87",
            params: newProduct,
            images: newProductImages
        )
        
        MarketAPIService().request(request) { [weak self] (result: Result<ProductDetail, Error>) in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self?.showAlert(title: "상품이 성공적으로 등록됐습니다", message: "🤑") { _ in
                        self?.dismiss(animated: true) {
                            self?.tableViewRefreshDelegate?.refresh()
                            self?.collectionViewRefreshDelegate?.refresh()
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "상품 등록에 실패했습니다", message: "🥲", handler: nil)
                }
                print("에러가 발생했습니다! : \(error)")
            }
        }
    }
    
    private func createNewProductInfo() -> NewProductInfo? {
        guard let name = nameTextField?.text else {
            return nil
        }
        guard let price = priceTextField?.text else {
            return nil
        }
        var currency: Currency
        if currencySegmentedControl?.selectedSegmentIndex == .zero {
            currency = .krw
        } else {
            currency = .usd
        }
        let discountedPrice = discountedPriceTextField?.text ?? "0"
        let stock = stockTextField?.text ?? "0"
        guard let descriptions = descriptionsTextView?.text else {
            return nil
        }
        
        let newProduct = NewProductInfo(
            name: name,
            descriptions: descriptions,
            price: (price as NSString).doubleValue,
            currency: currency,
            discountedPrice: (discountedPrice as NSString).doubleValue,
            stock: (stock as NSString).integerValue,
            secret: "aFJkk2KmB53A*6LT"
        )
        
        return newProduct
    }
    
    private func createImageFiles(newProductName: String) -> [ImageFile]? {
        var imageFileNumber = 1
        var newProductImages: [ImageFile] = []
        productImages.forEach { image in
            let imageFile = ImageFile(
                fileName: "\(newProductName)-\(imageFileNumber)",
                image: image
            )
            imageFileNumber += 1
            newProductImages.append(imageFile)
        }
        return newProductImages
    }
   
    private func presentAlert(excessImageAlert: ProductRegisterationViewModel.ExecessImageAlertViewModel) {
        let alert = UIAlertController(title: excessImageAlert.title,
                                      message: excessImageAlert.message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: excessImageAlert.actionTitle,
                                   style: .default) { _ in
            alert.dismiss(animated: false)
        }
        alert.addAction(action)
        self.present(alert, animated: false)
    }
}

// MARK: - Keyboard
extension ProductRegistrationViewController {
    
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
    
    private func addKeyboardDismissGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(_ sender: Notification) {
        if let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            scrollView?.contentInset.bottom = keyboardHeight
            scrollView?.verticalScrollIndicatorInsets.bottom = keyboardHeight
        }
    }
    
    @objc private func keyboardWillHide(_ sender: Notification) {
        scrollView?.contentInset.bottom = .zero
        scrollView?.verticalScrollIndicatorInsets.bottom = .zero
    }
    
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ProductRegistrationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let possibleImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.pickerImage.onNext(possibleImage)
        } else if let possibleImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.pickerImage.onNext(possibleImage)
        }
        cells.append(.productImageCell)
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate
extension ProductRegistrationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.nameTextField?.resignFirstResponder()
        return true
    }
}

extension ProductRegistrationViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == self.textViewPlaceHolder {
            self.descriptionsTextView?.text = ""
            self.descriptionsTextView?.textColor = .black
        }
        return true
    }
}
