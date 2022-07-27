//
//  ProductRegisterationSceneViewModel.swift
//  DotoriMarket
//
//  Created by lily on 2022/06/20.
//
 
import Foundation

import RxSwift
import RxCocoa

final class ProductRegisterationSceneViewModel {
    
    private let usecase: ProductRegisterationUsecase
    private let productRegisterationRecorder = ProductRegisterationRecorder()
    
    static let maximumProductImageCount = 5
    private var maximutProductImageCellCount: Int { ProductRegisterationSceneViewModel.maximumProductImageCount + 1 }

    init(usecase: ProductRegisterationUsecase) {
        self.usecase = usecase
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
        
        let isValidInput = self.usecase.isValidInput(
            image: productImages.asObservable(),
            name: input.productTitle.asObservable(),
            price: input.productPrice.asObservable(),
            stock: input.productStock.asObservable(),
            description: input.productDescriptionText.asObservable(),
            discountedPrice: input.prdouctDiscountedPrice.asObservable())
        
        let validationSuccess = isValidInput
            .filter{ (result, descritption) in result == .success }
            .map{ _ in }
        
        let requireSecretAlert = input.doneDidTapped
            .withLatestFrom(validationSuccess)
            .map{ _ in RequireSecretAlertViewModel() as AlertViewModel }
            .asDriver(onErrorJustReturn: ErrorAlertViewModel() as AlertViewModel)
    
        let validationFailAlert = input.doneDidTapped
            .withLatestFrom(isValidInput) { (request, validationResult) in return validationResult }
            .filter{ $0.0 == .failure }
            .map{ ValidationFailureAlertViewModel(title: $0.1, message: nil, actionTitle: MarketCommon.confirm.rawValue) as AlertViewModel }
            .asDriver(onErrorJustReturn: ErrorAlertViewModel() as AlertViewModel)
    
        let registrationFailureAlert = PublishSubject<AlertViewModel>()
        
        let registerationRequestResponse = input.didReceiveSecret
            .flatMap{ secret -> Observable<NewProductInfo> in
                return Observable.combineLatest(
                    input.productTitle.asObservable(),
                    input.productPrice.asObservable(),
                    input.prdouctDiscountedPrice.asObservable(),
                    productCurrency,
                    input.productStock.asObservable(),
                    input.productDescriptionText.asObservable(),
                    Observable.just(secret),
                                   resultSelector: { (name, price, discountedPrice, currency, stock, descritpion, secret) -> NewProductInfo in
                    return self.usecase.createNewProductInfo(
                        name: name,
                        price: price,
                        currency: currency,
                        discountedPrice: discountedPrice,
                        stock: stock,
                        description: descritpion,
                        secret: secret) })
            }
            .withLatestFrom(productImages,
                            resultSelector: { newProductInfo, imgaes in
                self.usecase.createRegistrationRequest(with: newProductInfo, productImages: imgaes) })
            .flatMap{ request in self.usecase.requestRegisterProduct(
                reqeust: request) }
        
        let registerationSucessAlert = registerationRequestResponse
            .observe(on: MainScheduler.instance)
            .do(onNext: { product in
                self.productRegisterationRecorder.recordProductRegistraion(productID: product.id)
            }, onError: { _ in
                registrationFailureAlert.onNext(RegistrationFailureAlertViewModel()) })
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
