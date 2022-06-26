//
//  ProductModificationViewController.swift
//  OpenMarket
//
//  Created by 1 on 2022/06/09.
//

import UIKit
import RxSwift
import RxCocoa

final class ProductModificationViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var scrollView: UIScrollView?
    @IBOutlet weak var productImageCollectionView: UICollectionView?
    @IBOutlet weak var productNameField: UITextField?
    @IBOutlet weak var prdouctPriceField: UITextField?
    @IBOutlet weak var productCurrencySegmentedControl: UISegmentedControl?
    @IBOutlet weak var productDisconutPriceField: UITextField?
    @IBOutlet weak var productStockField: UITextField?
    @IBOutlet weak var productDescriptionTextView: UITextView?
    @IBOutlet weak var doneButton: UIBarButtonItem?
    
    // MARK: - Property
    weak var refreshDelegate: RefreshDelegate?
    private var productID: Int?
    private let viewModel = ProductModificationSceneViewModel()
    private let disposeBag = DisposeBag()
    private let secret = PublishSubject<String>()
 
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionViewLayout()
        self.addKeyboardNotificationObserver()
        self.addKeyboardDismissGestureRecognizer()
        self.configureDelegate()
        self.bindViewModel()
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
    
    // MARK: - binding
    func bindViewModel() {
        let input = ProductModificationSceneViewModel.Input(viewWillAppear: self.rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:))).map{ _ in self.productID!},
                                                            productName: self.productNameField!.rx.text.asObservable(),
                                                            productPrice: self.prdouctPriceField!.rx.text.asObservable(),
                                                            productDiscountedPrice: self.productDisconutPriceField!.rx.text.asObservable(),
                                                            productCurrencyIndex: self.productCurrencySegmentedControl!.rx.selectedSegmentIndex.asObservable(),
                                                            productStock: self.productStockField!.rx.text.asObservable(),
                                                            productDescription: self.productDescriptionTextView!.rx.text.asObservable(),
                                                            didDoneTapped: self.doneButton!.rx.tap.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.prdouctName
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] name in
                self?.productNameField?.text = name }
            .disposed(by: disposeBag)
        
        output.productImagesURL
            .observe(on: MainScheduler.instance)
            .bind(to: productImageCollectionView!.rx.items(cellIdentifier: "PrdouctImageCollectionViewCell", cellType: ProductImageCollectionViewCell.self)) { (row, element, cell) in
                guard let imageURL = URL(string: element.thumbnailURL) else { return }
                if row == .zero {
                    cell.update(image: nil, url: imageURL, isRepresentaion: true)
                } else {
                    cell.update(image: nil, url: imageURL, isRepresentaion: false)
                }}
            .disposed(by: disposeBag)
        
        output.productPrice
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] price in
                self?.prdouctPriceField?.text = price }
            .disposed(by: disposeBag)
        
        output.productPrice
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] sellingPrice in
                self?.prdouctPriceField?.text = sellingPrice }
            .disposed(by: disposeBag)
        
        output.productStock
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] stock in
                self?.productStockField?.text = stock
            }
            .disposed(by: disposeBag)
        
        output.prodcutDiscountedPrice
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] price in
                self?.productDisconutPriceField?.text = price
            }
            .disposed(by: disposeBag)
        
        output.productCurrencyIndex
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] index in
                self?.productCurrencySegmentedControl?.selectedSegmentIndex = index }
            .disposed(by: disposeBag)
        
        output.productDescription
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] description in
                self?.productDescriptionTextView?.text = description }
            .disposed(by: disposeBag)
        
        output.validationFailureAlert
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] description in
                self?.presentValidationFailureAlert(viewModel: description) })
            .disposed(by: disposeBag)

        output.requireSecret
            .observe(on: MainScheduler.instance)
            .subscribe (onNext:{ viewModel in
                self.presentRequireSecretAlert(viewModel: viewModel) })
            .disposed(by: disposeBag)
    }
    
    private func presentValidationFailureAlert(viewModel: String?) {
        let alert = UIAlertController(title: viewModel, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: MarketCommon.confirm.rawValue, style: .default) { _ in
            alert.dismiss(animated: false)
        }
        alert.addAction(okAction)
        self.present(alert, animated: false)
    }
    
    private func presentRequireSecretAlert(viewModel: ProductModificationSceneViewModel.RequireSecretAlertViewModel) {
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
    
    // MARK: - IBAction
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    // MARK: -Method
    func setProduct(_ productID: Int) {
        self.productID = productID
    }
    
    private func configureDelegate() {
        self.productNameField?.delegate = self
    }
    
    private func presentValidationFailAlert(of description: String) {
        let alert = UIAlertController(title: description, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default)
        alert.addAction(okAction)
        self.present(alert, animated: false)
    }
    
    private func handleProductEditRequest() {
        let secretRequestAlert = UIAlertController(title: "판매자 비밀번호를 입력해주세요", message: nil, preferredStyle: .alert)
        secretRequestAlert.addTextField { textField in
            textField.clearButtonMode = .always
        }
        let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.requestProductEditAPI(with: secretRequestAlert.textFields?[0].text ?? "")
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) {  _ in
            secretRequestAlert.dismiss(animated: false)
        }
        secretRequestAlert.addAction(okAction)
        secretRequestAlert.addAction(cancelAction)

        self.present(secretRequestAlert, animated: false)
    }

    private func requestProductEditAPI(with secret: String) {
        guard let productID = self.productID else {
            return
        }

        let request = ProductEditRequest(
            identifier: "c4dedd67-71fc-11ec-abfa-fd97ecfece87",
            productID: productID,
            productInfo: self.createEditProductInfo(with: secret))

//        apiService.request(request) { [weak self] (result: Result<ProductDetail, Error>) in
//            switch result {
//            case .success:
//                DispatchQueue.main.async {
//                    self?.dismiss(animated: true)
//                    self?.refreshDelegate?.refresh()
//                }
//            case .failure:
//                DispatchQueue.main.async {
//                    self?.presentModificationFailureAlert()
//                }
//            }
//        }
    }

    private func createEditProductInfo(with secret: String) -> EditProductInfo {
        let price = self.prdouctPriceField?.text ?? ""
        let stock = self.productStockField?.text ?? ""
        let discountedPrice = self.productDisconutPriceField?.text ?? ""
        var currency: Currency
        if productCurrencySegmentedControl?.selectedSegmentIndex == .zero {
            currency = .krw
        } else {
            currency = .usd
        }

        return EditProductInfo(name: self.productNameField?.text,
                               descriptions: self.productDescriptionTextView?.text,
                               thumbnailID: nil,
                               price: (price as NSString).doubleValue,
                               currency: currency,
                               discountedPrice: (discountedPrice as NSString).doubleValue,
                               stock: (stock as NSString).integerValue,
                               secret: secret)
    }

    private func presentModificationFailureAlert() {
        let alert = UIAlertController(title: "비밀번호를 다시 확인해주세요", message: nil, preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "재시도", style: .default) { _ in
            self.handleProductEditRequest()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            alert.dismiss(animated: false)
        }
        alert.addAction(retryAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: false)
    }
}

// MARK: - Keyboard
extension ProductModificationViewController {
    
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

// MARK: - UITextFieldDelegate
extension ProductModificationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.productNameField?.resignFirstResponder()
        return true
    }
}
