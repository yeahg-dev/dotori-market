//
//  ProductRegisterationSceneViewModel.swift
//  OpenMarket
//
//  Created by 1 on 2022/06/20.
//

import Foundation
import RxSwift
import UIKit

final class ProductRegisterationSceneViewModel {
    
    private let APIService = MarketAPIService()
    
    static let maximumProductImageCount = 5
    private lazy var maximutProductImageCellCount = ProductRegisterationSceneViewModel.maximumProductImageCount + 1
    
    private let sellerIdentifier = "c4dedd67-71fc-11ec-abfa-fd97ecfece87"
    private let secretkey = "aFJkk2KmB53A*6LT"
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let itemSelected: Observable<Int>
        let didSelectImage: Observable<UIImage>
        let productTitle: Observable<String?>
        let productCurrency: Observable<Int>
        let productPrice: Observable<String?>
        let prdouctDiscountedPrice: Observable<String?>
        let productStock: Observable<String?>
        let productDescriptionText: Observable<String?>
        let didDoneTapped: Observable<Void>
        let didReceiveSecret: Observable<String>
    }
    
    struct Output {
        let textViewPlaceholder: Observable<String>
        let requireSecret: Observable<RequireSecretAlertViewModel>
        let presentImagePicker: Observable<Void>
        let productImages: Observable<[(CellType, UIImage)]>
        let excessImageAlert: Observable<ExecessImageAlertViewModel>
        let validationFailureAlert: Observable<String?>
        let registrationSuccessAlert: Observable<RegistrationSuccessAlertViewModel>
        let registrationFailureAlert: Observable<RegistrationFailureAlertViewModel>
    }
    
    func transform(input: Input) -> Output {
        let textViewPlaceholderText = MarketCommon.descriptionTextViewPlaceHolder.rawValue
        
        let textViewPlaceholder = input.viewWillAppear
            .map {textViewPlaceholderText }
        
        let defaultImage = input.viewWillAppear
            .map{ _ in [(CellType.imagePickerCell, UIImage())]}
        
        let selectedImage = input.didSelectImage
            .map { image in return [(CellType.productImageCell, image)]}
        
        let productImages = Observable.merge(defaultImage, selectedImage)
            .scan(into: []) { images, addedImage in
                images.append(contentsOf: addedImage) }
            .share(replay: 1)
        
        let isAbleToPickImage: Observable<Bool> = productImages
            .map { images in
                images.count < self.maximutProductImageCellCount }
        
        let presentImagePicker = input.itemSelected
            .filter { row in
                row == .zero }
            .withLatestFrom(isAbleToPickImage) { row, isAbleToPickImage in
                return isAbleToPickImage }
            .filter{ $0 == true }
            .map{ _ in }
        
        let excessImageAlert = input.itemSelected
            .filter { row in
                row == .zero }
            .withLatestFrom(isAbleToPickImage) { row, isAbleToPickImage in
                return isAbleToPickImage }
            .filter{ $0 == false }
            .map { _ in ExecessImageAlertViewModel() }
        
        let productName = input.productTitle.share(replay: 1)
        let productPrice = input.productPrice.share(replay: 1)
        let productStock = input.productStock.share(replay: 1)
        let productDescription = input.productDescriptionText.share(replay: 1)
        let productCurrency = input.productCurrency
        let productDiscountedPrice = input.prdouctDiscountedPrice
        
        let isValidImage = productImages.map { images in images.count > 1 }
        let isValidName = self.validate(name: productName).share(replay: 1)
        let isValidPrice = self.validate(price: productPrice).share(replay: 1)
        let isValidStock = self.validate(stock: productStock).share(replay: 1)
        let isvalidDescription = self.validate(description: productDescription).share(replay: 1)
        
        let validation = Observable.combineLatest(isValidImage, isValidName, isValidPrice, isValidStock, isvalidDescription, resultSelector: {
            self.validate(isValidImage: $0, isValidName: $1, isValidPrice: $2, isValidStock: $3, isValidDescription: $4)})
            .share(replay: 1)
        
        let validationSuccess = validation
            .filter({ (result, descritption) in
            result == .success })
            .map{ _ in }
        
        let requireSecret = input.didDoneTapped
            .withLatestFrom(validationSuccess)
            .map { _ in RequireSecretAlertViewModel() }
    
        let validationFail = input.didDoneTapped
            .withLatestFrom(validation) { (request, validationResult) in return validationResult }
            .filter { $0.0 == .failure }
            .map{ $0.1 }
    
        let registrationFailure = PublishSubject<RegistrationFailureAlertViewModel>()
        
        let newProductInfo = input.didReceiveSecret
            .flatMap { secret -> Observable<NewProductInfo> in
                return Observable.combineLatest(productName, productPrice, productDiscountedPrice, productCurrency, productStock, productDescription, Observable.just(secret),
                                   resultSelector: { (name, price, discountedPrice, currency, stock, descritpion, secret) -> NewProductInfo in
                    return self.createNewProductInfo(name: name, price: price, currency: currency, discountedPrice: discountedPrice, stock: stock, description: descritpion, secret: secret)
                }) }
        
        let registerationResponse = newProductInfo.withLatestFrom(productImages, resultSelector: { newProductInfo, imgaes in
            self.createRegistrationRequest(with: newProductInfo, productImages: imgaes) })
            .flatMap { request in
                self.APIService.requestRx(request) }
            .do(onError: { _ in
                registrationFailure.onNext(RegistrationFailureAlertViewModel()) })
            .retry(when: { _ in requireSecret })
            .map { _ in
                return RegistrationSuccessAlertViewModel() }
        
        return Output(textViewPlaceholder: textViewPlaceholder,
                      requireSecret: requireSecret,
                      presentImagePicker: presentImagePicker,
                      productImages: productImages,
                      excessImageAlert: excessImageAlert,
                      validationFailureAlert: validationFail,
                      registrationSuccessAlert: registerationResponse,
                      registrationFailureAlert: registrationFailure.asObservable() )
    }
    
}

// MARK: - Alert View Model
extension ProductRegisterationSceneViewModel {
 
    struct ExecessImageAlertViewModel {
        
        let title: String? = "사진은 최대 \(ProductRegisterationSceneViewModel.maximumProductImageCount)장까지 첨부할 수 있어요"
        let message: String? = nil
        let actionTitle: String? = "확인"
    }
    
    struct RequireSecretAlertViewModel {
        
        let title = "판매자 비밀번호를 입력해주세요"
        let actionTitle = "등록"
    }
    
    struct RegistrationSuccessAlertViewModel {
        
        let title = "성공적으로 등록되었습니다"
        let actionTitle = "상품 리스토로 돌아가기"
    }
    
    struct RegistrationFailureAlertViewModel {
        
        let title = "등록에 실패했습니다"
        let message = "다시 시도 해주세요"
        let actionTitle = "확인"
    }
    
    // MARK: - Input Validation
    enum ValidationResult {
        
        case success
        case failure
    }
    
    private func validate(isValidImage: Bool,
                          isValidName: Bool,
                          isValidPrice: Bool,
                          isValidStock: Bool,
                          isValidDescription: Bool) -> (ValidationResult, String?) {
        let category = [isValidImage, isValidName, isValidPrice, isValidStock, isValidDescription]
        
        if category.contains(false) {
            let description = self.makeAlertDescription(isValidImage: isValidImage,
                                                        isValidName: isValidName,
                                                        isValidPrice: isValidPrice,
                                                        isValidStock: isValidStock,
                                                        isValidDescription: isValidDescription)
            return (ValidationResult.failure, description)
        } else {
            return (ValidationResult.success, nil)
        }
    }
    
    private func makeAlertDescription(isValidImage: Bool,
                                      isValidName: Bool,
                                      isValidPrice: Bool,
                                      isValidStock: Bool,
                                      isValidDescription: Bool) -> String {
        let image = isValidImage ? "" : "대표 사진"
        let name = isValidName ? "" : "상품명"
        let price = isValidPrice ? "" : "가격"
        let stock = isValidStock ? "" : "재고"
        let description = isValidDescription ? "" : "상세정보"
        
        if isValidName == true && isValidPrice == true
            && isValidStock == true && isValidDescription == false {
            return "상세정보는 10자이상 1,000자이하로 작성해주세요"
        } else {
            let categories = [image, name, price, stock, description]
           
            let description = categories
                .filter { !$0.isEmpty }
                .reduce("") { partialResult, category in
                    partialResult.isEmpty ? category : "\(partialResult), \(category)"
                }
            
            if isValidDescription == false || isValidStock == false {
                return "\(description)는 필수 입력 항목이에요"
            } else {
                return "\(description)은 필수 입력 항목이에요"
            }
        }
    }
    
    private func validate(name: Observable<String?>) -> Observable<Bool> {
        return name.map { name -> Bool in
            guard let name = name else { return false }
            return name.isEmpty ? false : true
        }
    }
    
    private func validate(price: Observable<String?>) -> Observable<Bool> {
        return price.map { price -> Bool in
            guard let price = price else { return false }
            return price.isEmpty ? false : true
        }
    }
    
    private func validate(stock: Observable<String?>) -> Observable<Bool> {
        return stock.map { stock -> Bool in
            guard let stock = stock else { return false }
            return stock.isEmpty ? false : true
        }
    }
    
    private func validate(description: Observable<String?>) -> Observable<Bool> {
        return description.map { description -> Bool in
            guard let text = description else { return false }
            if text == MarketCommon.descriptionTextViewPlaceHolder.rawValue { return false }
            return text.count >= 10 && text.count <= 1000 ? true : false
        }
    }

    // MARK: - API Request
    enum ViewModelError: Error {
        case requestCreationFail
    }

    private func createRegistrationRequest(with productInfo: NewProductInfo, productImages: [(CellType, UIImage)]) -> ProductRegistrationRequest {
        let images = productImages.filter { image in image.0 == .productImageCell }
            .map { image in image.1 }
        let imageFiles = self.createImageFiles(newProductName: productInfo.name, productImages: images)
        let registrationRequest = ProductRegistrationRequest(identifier: self.sellerIdentifier,
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
            currency: currency,
            discountedPrice: ( discountedPrice as NSString).doubleValue,
            stock: (stock as NSString).integerValue,
            secret: secret )
    }
    
    private func createImageFiles(newProductName: String, productImages: [UIImage]) -> [ImageFile] {
        var imageFileNumber = 1
        var newProductImages: [ImageFile] = []
        productImages.forEach { image in
            let imageFile = ImageFile(
                fileName: "\(newProductName)-\(imageFileNumber)",
                image: image
            )
            imageFileNumber += 1
            newProductImages.append(imageFile) }
        return newProductImages
    }
    
}
