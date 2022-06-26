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
    
    struct Input {
        let viewWillAppear: Observable<Int>
        let productName: Observable<String?>
        let productPrice: Observable<String?>
        let productDiscountedPrice: Observable<String?>
        let productCurrencyIndex: Observable<Int>
        let productStock: Observable<String?>
        let productDescription: Observable<String?>
        let didDoneTapped: Observable<Void>
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
    }
    
    func transform(input: Input) -> Output {
        let productDetail = input.viewWillAppear
            .map { productID in
                ProductDetailRequest(productID: productID) }
            .flatMap { request -> Observable<ProductDetail> in
                self.APIService.requestRx(request) }
            .map { productDetail in
                ProductDetailViewModel(product: productDetail) }
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
        let productCurrency = input.productCurrencyIndex
        let productDiscountedPriceInput = input.productDiscountedPrice
        
        let isValidName = self.validate(name: productNameInput).share(replay: 1)
        let isValidPrice = self.validate(price: productPriceInput).share(replay: 1)
        let isValidStock = self.validate(stock: productStockInput).share(replay: 1)
        let isvalidDescription = self.validate(description: productDescriptionInput).share(replay: 1)
        
        let isValidate = Observable.combineLatest(isValidName, isValidPrice, isValidStock, isvalidDescription, resultSelector: {
            self.validate(isValidName: $0, isValidPrice: $1, isValidStock: $2, isValidDescription: $3)})
            .share(replay: 1)
        
        let validationSuccess = isValidate
            .filter({ (result, descritption) in
            result == .success })
            .map{ _ in }
        
        let requireSecret = input.didDoneTapped
            .withLatestFrom(validationSuccess)
            .map { _ in RequireSecretAlertViewModel() }
    
        let validationFail = input.didDoneTapped
            .withLatestFrom(isValidate) { (request, validationResult) in return validationResult }
            .filter { $0.0 == .failure }
            .map{ $0.1 }
        
        return Output(prdouctName: productName,
                      productImagesURL: productImages,
                      productPrice: productPrice,
                      prodcutDiscountedPrice: productDiscountedPrice,
                      productCurrencyIndex: productCurrencyIndex,
                      productStock: productStock,
                      productDescription: prodcutDescription,
                      validationFailureAlert: validationFail,
                      requireSecret: requireSecret)
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

}
