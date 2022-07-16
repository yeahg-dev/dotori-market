//
//  ProductRegisterationSceneViewModel.swift
//  OpenMarket
//
//  Created by 1 on 2022/06/20.
//

import Foundation

import RxSwift
import RxCocoa

final class ProductRegisterationSceneViewModel {
    
    private var APIService: APIServcie
    private let productInputChecker = ProductInputChecker()
    static let maximumProductImageCount = 5
    private var maximutProductImageCellCount: Int { ProductRegisterationSceneViewModel.maximumProductImageCount + 1 }

    init(APIService: APIServcie) {
        self.APIService = APIService
    }
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let imagePickerCellDidSelected: Observable<Int>
        let imageDidSelected: Observable<Data>
        let productTitle: ControlProperty<String?>
        let productCurrency: ControlProperty<Int>
        let productPrice: ControlProperty<String?>
        let prdouctDiscountedPrice: ControlProperty<String?>
        let productStock: ControlProperty<String?>
        let productDescriptionText: ControlProperty<String?>
        let doneDidTapped: ControlEvent<Void>
        let didReceiveSecret: Observable<String>
    }
    
    struct Output {
        let textViewPlaceholder: Driver<String>
        let requireSecret: Driver<AlertViewModel>
        let presentImagePicker: Driver<Void>
        let productImages: Driver<[(CellType, Data)]>
        let excessImageAlert: Driver<AlertViewModel>
        let validationFailureAlert: Driver<AlertViewModel>
        let registrationSuccessAlert: Driver<AlertViewModel>
        let registrationFailureAlert: Driver<AlertViewModel>
    }
    
    func transform(input: Input) -> Output {
        let textViewPlaceholderText = MarketCommon.descriptionTextViewPlaceHolder.rawValue
        
        let textViewPlaceholder = input.viewWillAppear
            .map{ textViewPlaceholderText }
            .asDriver(onErrorJustReturn: "")
        
        let pickerCellImage = input.viewWillAppear
            .map{ _ in [(CellType.imagePickerCell, Data())] }
        
        let selectedImage = input.imageDidSelected
            .map{ image in return [(CellType.productImageCell, image)] }
        
        let productImages = Observable.merge(pickerCellImage, selectedImage)
            .scan(into: []) { images, addedImage in
                images.append(contentsOf: addedImage) }
            .asDriver(onErrorJustReturn: [])
        
        let isAbleToPickImage: Observable<Bool> = productImages
            .asObservable()
            .map{ images in
                images.count < self.maximutProductImageCellCount }
        
        let presentImagePicker = input.imagePickerCellDidSelected
            .withLatestFrom(isAbleToPickImage) { row, isAbleToPickImage in
                return isAbleToPickImage }
            .filter{ $0 == true }
            .map{ _ in }
            .asDriver(onErrorJustReturn: ())
        
        let excessImageAlert = input.imagePickerCellDidSelected
            .withLatestFrom(isAbleToPickImage) { row, isAbleToPickImage in
                return isAbleToPickImage }
            .filter{ $0 == false }
            .map{ _ in ExecessImageAlertViewModel() as AlertViewModel }
            .asDriver(onErrorJustReturn: ErrorAlertViewModel() as AlertViewModel)
        
        let productCurrency = input.productCurrency.asObservable()

        let isValidImage = productImages.asObservable().map { images in images.count > 1 }
        let isValidName = productInputChecker.isValid(name: input.productTitle.asObservable())
        let isValidPrice = productInputChecker.isValid(price: input.productPrice.asObservable())
        let isValidStock = productInputChecker.isValid(stock: input.productStock.asObservable())
        let isvalidDescription = productInputChecker.isValid(description: input.productDescriptionText.asObservable())
        let isValidDiscountedPrice = productInputChecker.isValid(discountedPrice: input.prdouctDiscountedPrice.asObservable(), price: input.productPrice.asObservable())
        
        let validation = Observable.combineLatest(isValidImage, isValidName, isValidPrice, isValidStock, isvalidDescription, isValidDiscountedPrice, resultSelector: {
            self.productInputChecker.validationResultOf(isValidImage: $0, isValidName: $1, isValidPrice: $2, isValidStock: $3, isValidDescription: $4, isValidDiscountedPrice: $5)})
            .share(replay: 1)
        
        let validationSuccess = validation
            .filter{ (result, descritption) in result == .success }
            .map{ _ in }
        
        let requireSecretAlert = input.doneDidTapped
            .withLatestFrom(validationSuccess)
            .map{ _ in RequireSecretAlertViewModel() as AlertViewModel }
            .asDriver(onErrorJustReturn: ErrorAlertViewModel() as AlertViewModel)
    
        let validationFailAlert = input.doneDidTapped
            .withLatestFrom(validation) { (request, validationResult) in return validationResult }
            .filter{ $0.0 == .failure }
            .map{ ValidationFailureAlertViewModel(title: $0.1, message: nil, actionTitle: MarketCommon.confirm.rawValue) as AlertViewModel }
            .asDriver(onErrorJustReturn: ErrorAlertViewModel() as AlertViewModel)
    
        let registrationFailureAlert = PublishSubject<AlertViewModel>()
        
        let newProductInfo = input.didReceiveSecret
            .flatMap{ secret -> Observable<NewProductInfo> in
                return Observable.combineLatest(input.productTitle.asObservable(), input.productPrice.asObservable(), input.prdouctDiscountedPrice.asObservable(), productCurrency, input.productStock.asObservable(), input.productDescriptionText.asObservable(), Observable.just(secret),
                                   resultSelector: { (name, price, discountedPrice, currency, stock, descritpion, secret) -> NewProductInfo in
                    return self.createNewProductInfo(name: name, price: price, currency: currency, discountedPrice: discountedPrice, stock: stock, description: descritpion, secret: secret)
                }) }
        
        let requestProductRegistration = newProductInfo.withLatestFrom(productImages,
                                                                       resultSelector: { newProductInfo, imgaes in
                 self.createRegistrationRequest(with: newProductInfo, productImages: imgaes) })
                 .flatMap{ request in self.APIService.requestRx(request) }
        
        let registerationSucessAlert = requestProductRegistration
            .do(onError: { _ in
                registrationFailureAlert.onNext(RegistrationFailureAlertViewModel()) })
            .retry(when: { _ in requireSecretAlert.asObservable() })
            .map{ _ in return RegistrationSuccessAlertViewModel() as AlertViewModel }
            .asDriver(onErrorJustReturn: ErrorAlertViewModel() as AlertViewModel)
        
        return Output(textViewPlaceholder: textViewPlaceholder,
                      requireSecret: requireSecretAlert,
                      presentImagePicker: presentImagePicker,
                      productImages: productImages,
                      excessImageAlert: excessImageAlert,
                      validationFailureAlert: validationFailAlert.asDriver(onErrorJustReturn: ErrorAlertViewModel() as AlertViewModel),
                      registrationSuccessAlert: registerationSucessAlert,
                      registrationFailureAlert: registrationFailureAlert .asDriver(onErrorJustReturn: ErrorAlertViewModel() as AlertViewModel))
    }
    
}

extension ProductRegisterationSceneViewModel {
    
    // MARK: - API Request
    
    private func createRegistrationRequest(with productInfo: NewProductInfo, productImages: [(CellType, Data)]) -> ProductRegistrationRequest {
        let imageDatas = productImages.filter{ image in image.0 == .productImageCell }
            .map{ image in image.1 }
        let imageFiles = imageDatas.imageFile(fileName: productInfo.name)
        let registrationRequest = ProductRegistrationRequest(identifier: SellerInformation.identifier.rawValue,
                                                             params: productInfo,
                                                             images: imageFiles)
        return registrationRequest
    }
    
    private func createNewProductInfo(name: String?,
                                      price: String?,
                                      currency: Int?,
                                      discountedPrice: String?,
                                      stock: String?,
                                      description: String?,
                                      secret: String) -> NewProductInfo {
        let currency: Currency = currency == .zero ? .krw : .usd
        guard let name = name,
              let price = price,
              let discountedPrice = discountedPrice,
              let stock = stock,
              let description = description else {
            return NewProductInfo(name: "",
                                  descriptions: "",
                                  price: 0,
                                  currency: .usd,
                                  discountedPrice: 0,
                                  stock: 0,
                                  secret: "")
        }

        return NewProductInfo(
            name: name,
            descriptions: description,
            price: (price as NSString).doubleValue,
            currency: currency.toEntity(),
            discountedPrice: ( discountedPrice as NSString).doubleValue,
            stock: (stock as NSString).integerValue,
            secret: secret )
    }
    
}
