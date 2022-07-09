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
    
    private let imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        return imagePicker
    }()
    private let flowLayout = UICollectionViewFlowLayout()
    private var textViewPlaceHolder: String?
    
    // MARK: - Property
    
    private let viewModel = ProductRegisterationSceneViewModel(APIService: MarketAPIService())
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
    
    // MARK: - binding
    
    private func bindViewModel() {
        guard let productImageCollectionView = self.productImageCollectionView,
              let nameTextField = self.nameTextField,
              let currencySegmentedControl = self.currencySegmentedControl,
              let priceTextField = self.priceTextField,
              let discountedPriceTextField = self.discountedPriceTextField,
              let stockTextField = self.stockTextField,
              let descriptionsTextView = self.descriptionsTextView else {
            return
        }

        guard let doneButton = self.navigationBar?.items?[0].rightBarButtonItem as? UIBarButtonItem else { return }
        
        let input = ProductRegisterationSceneViewModel.Input(
            viewWillAppear: self.rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:))).map{_ in },
            cellDidSelected: productImageCollectionView.rx.itemSelected.map{ index in index.row },
            imageDidSelected: self.pickerImage,
            productTitle: nameTextField.rx.text.asObservable(),
            productCurrency: currencySegmentedControl.rx.value.asObservable(),
            productPrice: priceTextField.rx.text.asObservable(),
            prdouctDiscountedPrice: discountedPriceTextField.rx.text.asObservable(),
            productStock: stockTextField.rx.text.asObservable(),
            productDescriptionText: descriptionsTextView.rx.text.asObservable(),
            doneDidTapped: doneButton.rx.tap.asObservable(),
            didReceiveSecret: self.secret.asObservable())
        
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
            .bind(to: productImageCollectionView.rx.items) { [weak self] (tableView, row, element) in
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
                    return cell }}
                .disposed(by: disposeBag)
        
        output.excessImageAlert
            .observe(on: MainScheduler.instance)
            .subscribe{ [weak self] excessImageAlert in
                self?.presentAlert(excessImageAlert: excessImageAlert) }
            .disposed(by: disposeBag)
        
        output.validationFailureAlert
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] description in
                self?.presentValidationFailureAlert(viewModel: description) })
            .disposed(by: disposeBag)
        
        output.requireSecret
            .observe(on: MainScheduler.instance)
            .subscribe(onNext:{ [weak self] viewModel in
                self?.presentRequireSecretAlert(viewModel: viewModel) })
            .disposed(by: disposeBag)
        
        output.registrationFailureAlert
            .observe(on: MainScheduler.instance)
            .subscribe(onNext:{ [weak self] viewModel in
                self?.presentRegistrationFailureAlert(viewModel: viewModel) })
            .disposed(by: disposeBag)

        output.registrationSuccessAlert
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] viewModel in
                self?.presentRegistrationSuccessAlert(viewModel: viewModel) })
            .disposed(by: disposeBag)
                
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
        self.navigationBar?.standardAppearance = navigationAppearance
    }
    
    private func configureFlowLayout() {
        self.productImageCollectionView?.collectionViewLayout = flowLayout
        self.flowLayout.scrollDirection = .horizontal
        self.productImageCollectionView?.showsVerticalScrollIndicator = false
        self.productImageCollectionView?.showsHorizontalScrollIndicator = false
        
        let cellWidth = view.bounds.size.width / 4
        self.flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        self.flowLayout.minimumLineSpacing = 10
        self.flowLayout.sectionInset = UIEdgeInsets(top: .zero, left: 10, bottom: .zero, right: 10)
    }

    // MARK: - IBaction Method
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    // MARK: - Present Alert
    
    private func presentAlert(excessImageAlert: ProductRegisterationSceneViewModel.ExecessImageAlertViewModel) {
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
    
    private func presentValidationFailureAlert(viewModel: String?) {
        let alert = UIAlertController(title: viewModel, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: MarketCommon.confirm.rawValue, style: .default) { _ in
            alert.dismiss(animated: false)
        }
        alert.addAction(okAction)
        self.present(alert, animated: false)
    }
    
    private func presentRequireSecretAlert(viewModel: ProductRegisterationSceneViewModel.RequireSecretAlertViewModel) {
        let alert = UIAlertController(title: viewModel.title, message: nil, preferredStyle: .alert)
        alert.addTextField()
        alert.textFields?[0].isSecureTextEntry = true
        let sendAction = UIAlertAction(title: viewModel.actionTitle, style: .default) { _ in
            guard let secret = alert.textFields?[0].text else { return }
            self.secret.onNext(secret)
            alert.dismiss(animated: false)
        }
        alert.addAction(sendAction)
        
        self.present(alert, animated: false)
    }
    
    private func presentRegistrationFailureAlert(viewModel: ProductRegisterationSceneViewModel.RegistrationFailureAlertViewModel) {
        let alert = UIAlertController(title: viewModel.title , message: viewModel.message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: viewModel.actionTitle, style: .default) { _ in
            alert.dismiss(animated: false)
        }
        alert.addAction(okAction)
        self.present(alert, animated: false)
    }
    
    private func presentRegistrationSuccessAlert(viewModel: ProductRegisterationSceneViewModel.RegistrationSuccessAlertViewModel) {
        let alert = UIAlertController(title: viewModel.title, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: viewModel.actionTitle, style: .default) { [weak self] _ in
            alert.dismiss(animated: false)
            self?.dismiss(animated: false)
        }
        alert.addAction(okAction)
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
        self.view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(_ sender: Notification) {
        if let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.scrollView?.contentInset.bottom = keyboardHeight
            self.scrollView?.verticalScrollIndicatorInsets.bottom = keyboardHeight
        }
    }
    
    @objc private func keyboardWillHide(_ sender: Notification) {
        self.scrollView?.contentInset.bottom = .zero
        self.scrollView?.verticalScrollIndicatorInsets.bottom = .zero
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
        self.imagePicker.dismiss(animated: true, completion: nil)
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

// MARK: - UITextViewDelegate

extension ProductRegistrationViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == MarketCommon.descriptionTextViewPlaceHolder.rawValue {
            self.descriptionsTextView?.text = ""
            self.descriptionsTextView?.textColor = .black
        }
        return true
    }
}
