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
    
    private let coordinator: ProductRegisterationCoordinator
    private let viewModel: ProductRegisterationSceneViewModel
    private let disposeBag = DisposeBag()
    private let pickerImage = PublishSubject<Data>()
    private let secret = PublishSubject<String>()
    private var cells: [CellType] = [.imagePickerCell]
    
    // MARK: - Initializer
    
    init?(viewModel: ProductRegisterationSceneViewModel,
          coordinator: ProductRegisterationCoordinator,
          coder: NSCoder) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
            imagePickerCellDidSelected: productImageCollectionView.rx.itemSelected.map{ index in index.row }.filter{ $0 == .zero },
            imageDidSelected: self.pickerImage.asObservable(),
            productTitle: nameTextField.rx.text,
            productCurrency: currencySegmentedControl.rx.value,
            productPrice: priceTextField.rx.text,
            prdouctDiscountedPrice: discountedPriceTextField.rx.text,
            productStock: stockTextField.rx.text,
            productDescriptionText: descriptionsTextView.rx.text,
            doneDidTapped: doneButton.rx.tap,
            didReceiveSecret: self.secret.asObservable())
        
        let output = self.viewModel.transform(input: input)
        
        output.presentImagePicker
            .drive(onNext: { [weak self] _ in
                guard let imagePickerController = self?.imagePicker else { return }
                self?.present(imagePickerController, animated: false) })
            .disposed(by: disposeBag)
        
        output.textViewPlaceholder
            .drive(onNext: { [weak self] (placeholder: String) in
                self?.textViewPlaceHolder = placeholder
                self?.descriptionsTextView?.text = placeholder
                self?.descriptionsTextView?.font = .preferredFont(forTextStyle: .footnote)
                self?.descriptionsTextView?.textColor = .systemGray2 })
            .disposed(by: disposeBag)
        
        output.productImages
            .drive(productImageCollectionView.rx.items) { [weak self] (tableView, row, element) in
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
                    let image = UIImage(data: element.1) ?? UIImage(systemName: "exclamationmark.icloud")
                    if row == 1 {
                        cell.updateProductImageView(image: image, isRepresentaion: true)
                    } else {
                        cell.updateProductImageView(image: image, isRepresentaion: false)
                    }
                    return cell }}
                .disposed(by: disposeBag)
        
        output.excessImageAlert
            .drive{ [weak self] excessImageAlert in
                self?.presentAlertWithDismiss(alertViewModel: excessImageAlert) }
            .disposed(by: disposeBag)
        
        output.validationFailureAlert
            .drive(onNext: { [weak self] viewModel in
                self?.presentAlertWithDismiss(alertViewModel: viewModel) })
            .disposed(by: disposeBag)
        
        output.requireSecret
            .drive(onNext:{ [weak self] viewModel in
                self?.presentRequireSecretAlert(viewModel: viewModel) }) 
            .disposed(by: disposeBag)
        
        output.registrationFailureAlert
            .drive(onNext:{ [weak self] viewModel in
                self?.presentAlertWithDismiss(alertViewModel: viewModel) })
            .disposed(by: disposeBag)

        output.registrationSuccessAlert
            .drive(onNext: { [weak self] viewModel in
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
        self.navigationBar?.tintColor = DotoriColorPallete.identityColor
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
    
    private func presentAlertWithDismiss(alertViewModel: AlertViewModel) {
        let alert = UIAlertController(title: alertViewModel.title,
                                      message: alertViewModel.message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: alertViewModel.actionTitle,
                                   style: .default) { _ in
            alert.dismiss(animated: false)
        }
        action.setValue(DotoriColorPallete.identityHighlightColor,
                        forKey: "titleTextColor")
        alert.addAction(action)
        self.present(alert, animated: false)
    }
    
    private func presentRequireSecretAlert(viewModel: AlertViewModel) {
        let alert = UIAlertController(title: viewModel.title, message: nil, preferredStyle: .alert)
        alert.addTextField()
        alert.textFields?[0].isSecureTextEntry = true
        let sendAction = UIAlertAction(title: viewModel.actionTitle, style: .default) { _ in
            guard let secret = alert.textFields?[0].text else { return }
            self.secret.onNext(secret)
            alert.dismiss(animated: false)
        }
        sendAction.setValue(DotoriColorPallete.identityHighlightColor,
                            forKey: "titleTextColor")
        alert.addAction(sendAction)
        
        self.present(alert, animated: false)
    }
    
    private func presentRegistrationSuccessAlert(viewModel: AlertViewModel) {
        let alert = UIAlertController(title: viewModel.title, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: viewModel.actionTitle, style: .default) { [weak self] _ in
            alert.dismiss(animated: false)
            self?.coordinator.transitionToAllProduct()
            self?.coordinator.childDidFinish(self?.coordinator)
            self?.dismiss(animated: false)
        }
        okAction.setValue(DotoriColorPallete.identityHighlightColor,
                          forKey: "titleTextColor")
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
        
        if let possibleImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage,
           let data = possibleImage.jpegData(compressionQuality: 1) {
            self.pickerImage.onNext(data)
        } else if let possibleImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
                  let data = possibleImage.jpegData(compressionQuality: 1){
            self.pickerImage.onNext(data)
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
