//
//  ProductModificationSceneViewModel.swift
//  OpenMarket
//
//  Created by 1 on 2022/06/26.
//

import Foundation
import RxSwift

final class ProductModificationSceneViewModel {
    
    private let APIService = MarketAPIService()
    private let sellerIdentifier = "c4dedd67-71fc-11ec-abfa-fd97ecfece87"
    private var productID: Int?
    
    struct Input {
        let viewWillAppear: Observable<Int>
        let productName: Observable<String?>
        let productPrice: Observable<String?>
        let productDiscountedPrice: Observable<String?>
        let productCurrencyIndex: Observable<Int>
        let productStock: Observable<String?>
        let productDescription: Observable<String?>
        let didDoneTapped: Observable<Void>
        let didReceiveSecret: Observable<String>
    }
    
    struct Output {
        let prdouctName: Observable<String>
        let productImagesURL: Observable<[Image]>
        let productPrice: Observable<String?>
        let prodcutDiscountedPrice: Observable<String?>
        let productCurrencyIndex: Observable<Int>
        let productStock: Observable<String>
        let productDescription: Observable<String>
        let validationFailureAlert: Observable<String?>
        let requireSecret: Observable<RequireSecretAlertViewModel>
        let registrationSuccessAlert: Observable<Void>
        let registrationFailureAlert: Observable<ModificationFailureAlertViewModel>
    }
    
    func transform(input: Input) -> Output {
        let productDetail = input.viewWillAppear
            .do(onNext: { productID in
                self.productID = productID })
            .map { productID in
                ProductDetailRequest(productID: productID) }
            .flatMap { request -> Observable<ProductDetail> in
                self.APIService.requestRx(request) }
            .map { productDetail in
                ProductDetailModificationViewModel(product: productDetail) }
            .share(replay: 1)
        
        let productName = productDetail.map { $0.name }
        let productPrice = productDetail.map { $0.price }
        let productDiscountedPrice = productDetail.map { $0.discountedPrice }
        let productStock = productDetail.map { $0.stock }
        let prodcutDescription = productDetail.map { $0.description }
        let productImages = productDetail.map { $0.images }
        let productCurrencyIndex = productDetail.map { $0.currency }
            .map { currency -> Int in
                switch currency {
                case .krw:
                    return 0
                case .usd:
                    return 1
                }
            }
        
        let productNameInput = input.productName.share(replay: 1)
        let productPriceInput = input.productPrice.share(replay: 1)
        let productStockInput = input.productStock.share(replay: 1)
        let productDescriptionInput = input.productDescription.share(replay: 1)
        
        let isValidName = self.validate(name: productNameInput).share(replay: 1)
        let isValidPrice = self.validate(price: productPriceInput).share(replay: 1)
        let isValidStock = self.validate(stock: productStockInput).share(replay: 1)
        let isvalidDescription = self.validate(description: productDescriptionInput).share(replay: 1)
        
        let requireSecret = input.didDoneTapped
            .flatMap({ _ in
                Observable.zip(isValidName, isValidPrice, isValidStock, isvalidDescription, resultSelector: { self.validate(isValidName: $0, isValidPrice: $1, isValidStock: $2, isValidDescription: $3) })
            })
            .filter { (result, descritpion) in
                result == .success }
            .map { _ in RequireSecretAlertViewModel() }
    
        let validationFail = input.didDoneTapped
            .flatMap({ _ in
                Observable.zip(isValidName, isValidPrice, isValidStock, isvalidDescription, resultSelector: { self.validate(isValidName: $0, isValidPrice: $1, isValidStock: $2, isValidDescription: $3) })
            })
            .filter { (result, descritpion) in
                result == .failure }
            .map { (result, description) in description }
        
        let registrationFailure = PublishSubject<ModificationFailureAlertViewModel>()
        
        let registerationResponse = input.didReceiveSecret
            .flatMap { secret -> Observable<EditProductInfo?> in
                return Observable.combineLatest(productNameInput, productPriceInput, input.productDiscountedPrice, input.productCurrencyIndex, productStockInput, productDescriptionInput, Observable.just(secret),
                                   resultSelector: { (name, price, discountedPrice, currency, stock, descritpion, secret) -> EditProductInfo? in
                    return self.createEditProductInfo(name: name, description: descritpion, price: price, currencyIndex: currency, discountedPrice: discountedPrice, stock: stock, secret: secret)
                }) }
            .flatMap({ productInfo in
                self.createModificationRequest(with: productInfo) })
            .flatMap { request in
                // FIXME: - 요청 시도 횟수만큼 상품이 등록되는 오류
                self.APIService.requestRx(request) }
            .do(onError: { _ in
                registrationFailure.onNext(ModificationFailureAlertViewModel()) })
            .retry(when: { _ in requireSecret })
            .map { _ in }
        
        return Output(prdouctName: productName,
                      productImagesURL: productImages,
                      productPrice: productPrice,
                      prodcutDiscountedPrice: productDiscountedPrice,
                      productCurrencyIndex: productCurrencyIndex,
                      productStock: productStock,
                      productDescription: prodcutDescription,
                      validationFailureAlert: validationFail,
                      requireSecret: requireSecret,
                      registrationSuccessAlert: registerationResponse,
                      registrationFailureAlert: registrationFailure)
    }
}


extension ProductModificationSceneViewModel {
    
    // TODO: - 등록/수정화면 공통 사용요소
    enum Placeholder: String {
        
        case textView = "상품 상세 정보를 입력해주세요.\n(최소 10 ~ 최대 1,000 글자 작성 가능 😊)"
    }
    
    struct RequireSecretAlertViewModel {
        
        let title = "판매자 비밀번호를 입력해주세요"
        let actionTitle = "등록"
    }
   
    struct ModificationFailureAlertViewModel {
        
        let title = "수정에 실패했습니다"
        let message = "다시 시도 해주세요"
        let actionTitle = "확인"
    }
    
    // MARK: - Input Validation
    enum ValidationResult {
        
        case success
        case failure
    }
    
    private func validate(isValidName: Bool,
                          isValidPrice: Bool,
                          isValidStock: Bool,
                          isValidDescription: Bool) -> (ValidationResult, String?) {
        let category = [isValidName, isValidPrice, isValidStock, isValidDescription]
        
        if category.contains(false) {
            let description = self.makeAlertDescription(isValidName: isValidName,
                                                        isValidPrice: isValidPrice,
                                                        isValidStock: isValidStock,
                                                        isValidDescription: isValidDescription)
            return (ValidationResult.failure, description)
        } else {
            return (ValidationResult.success, nil)
        }
    }
    
    private func makeAlertDescription(isValidName: Bool,
                                      isValidPrice: Bool,
                                      isValidStock: Bool,
                                      isValidDescription: Bool) -> String {
        let name = isValidName ? "" : "상품명"
        let price = isValidPrice ? "" : "가격"
        let stock = isValidStock ? "" : "재고"
        let description = isValidDescription ? "" : "상세정보"
        
        if isValidName == true && isValidPrice == true
            && isValidStock == true && isValidDescription == false {
            return "상세정보는 10자이상 1,000자이하로 작성해주세요"
        } else {
            let categories = [name, price, stock, description]
           
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
            if text == Placeholder.textView.rawValue { return false }
            return text.count >= 10 && text.count <= 1000 ? true : false
        }
    }

    enum ViewModelError: Error {
        case requestCreationFail
    }

    private func createModificationRequest(with productInfo: EditProductInfo?) -> Observable<ProductEditRequest> {
        let editRequest = Observable<ProductEditRequest>.create { observer in
            guard let id = self.productID,
                let productInfo = productInfo else {
                observer.onError(ViewModelError.requestCreationFail)
                return Disposables.create()
            }
            let request = ProductEditRequest(
                identifier: self.sellerIdentifier,
                productID: id,
                productInfo: productInfo)
            observer.onNext(request)
            return Disposables.create()
        }
        return editRequest
    }
    
    private func createEditProductInfo(name: String?, description: String?, price: String?, currencyIndex: Int, discountedPrice: String?, stock: String?, secret: String) -> EditProductInfo? {
        guard let name = name,
              let description = description,
              let price = price,
              let discountedPrice = discountedPrice,
              let stock = stock else {
            return nil
        }
        let currency: Currency
        if currencyIndex == .zero {
            currency = .krw
        } else {
            currency = .usd
        }

        return EditProductInfo(name: name,
                               descriptions: description,
                               thumbnailID: nil,
                               price: (price as NSString).doubleValue,
                               currency: currency,
                               discountedPrice: (discountedPrice as NSString).doubleValue,
                               stock: (stock as NSString).integerValue,
                               secret: secret)
    }

}
