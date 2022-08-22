//
//  ProductRegisterationSceneViewModel.swift
//  DotoriMarket
//
//  Created by lily on 2022/06/20.
//
 
import Foundation

import RxSwift
import RxCocoa

final class ProductRegistrationSceneViewModel {
    
    private let usecase: ProductRegistrationUsecase
    
    static let maximumProductImageCount = 5
    private let imagePickerCellCount = 1
    private var maximutProductImageCellCount: Int {
        ProductRegistrationSceneViewModel.maximumProductImageCount + imagePickerCellCount }

    init(usecase: ProductRegistrationUsecase) {
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
        
        let productCellImages = Observable.merge(pickerCellImage, selectedImage)
            .scan(into: []) { images, addedImage in
                images.append(contentsOf: addedImage) }
            .share(replay: 1)
        
        let isAbleToPickImage: Observable<Bool> = productCellImages
            .map{ images in
                images.count <= self.maximutProductImageCellCount }
        
        let presentImagePicker = input.imagePickerCellDidSelected
            .withLatestFrom(isAbleToPickImage) { row, isAbleToPickImage in
                let isPickerCell = (row == 0)
                let isImageFullySelected = isAbleToPickImage
                return isPickerCell && isImageFullySelected }
            .filter{ $0 == true }
            .map{ _ in }
            .asDriver(onErrorJustReturn: ())
        
        let excessImageAlert = input.imagePickerCellDidSelected
            .withLatestFrom(isAbleToPickImage) { row, isAbleToPickImage in
                return isAbleToPickImage }
            .filter{ $0 == false }
            .map{ _ in ExecessImageAlertViewModel() as AlertViewModel }
            .asDriver(onErrorJustReturn: ErrorAlertViewModel() as AlertViewModel)
        
        let isValidInput = self.usecase.isValidInput(
            image: productCellImages.asObservable(),
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
            .withLatestFrom(isValidInput) { (request, validationResult) in
                return validationResult }
            .filter{ $0.0 == .failure }
            .map{ ValidationFailureAlertViewModel(
                title: $0.1,
                message: nil,
                actionTitle: MarketCommon.confirm.rawValue) as AlertViewModel }
            .asDriver(onErrorJustReturn: ErrorAlertViewModel() as AlertViewModel)
    
        let registrationFailureAlert = PublishSubject<AlertViewModel>()
        
        let registrationSucessAlert = input.didReceiveSecret
            .flatMap{ secret in
                self.usecase.requestProductRegistration(
                    name: input.productTitle.asObservable(),
                    price: input.productPrice.asObservable(),
                    currency: input.productCurrency.asObservable(),
                    discountedPrice: input.prdouctDiscountedPrice.asObservable(),
                    stock: input.productStock.asObservable(),
                    description: input.productDescriptionText.asObservable(),
                    secret: Observable.just(secret),
                    image: productCellImages.asObservable())}
            .do(onError: { _ in
                registrationFailureAlert.onNext(RegistrationFailureAlertViewModel()) })
            .retry(when: { _ in requireSecretAlert.asObservable() })
            .map{ _ in return RegistrationSuccessAlertViewModel() as AlertViewModel }
            .asDriver(onErrorJustReturn: ErrorAlertViewModel() as AlertViewModel)
        
        return Output(textViewPlaceholder: textViewPlaceholder,
                      requireSecret: requireSecretAlert,
                      presentImagePicker: presentImagePicker,
                      productImages: productCellImages.asDriver(onErrorJustReturn: []),
                      excessImageAlert: excessImageAlert,
                      validationFailureAlert: validationFailAlert.asDriver(
                        onErrorJustReturn: ErrorAlertViewModel() as AlertViewModel),
                      registrationSuccessAlert: registrationSucessAlert,
                      registrationFailureAlert: registrationFailureAlert .asDriver(
                        onErrorJustReturn: ErrorAlertViewModel() as AlertViewModel))
    }
    
}
