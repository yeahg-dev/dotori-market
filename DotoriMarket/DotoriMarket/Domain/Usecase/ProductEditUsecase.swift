//
//  ProductEditUsecase.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/26.
//

import Foundation

import RxSwift

struct ProductEditUsecase {
    
    private let productRepository: ProductRepository
    private let inputChecker = ProductInputChecker()
    
    init(productRepository: MarketProductRepository = MarketProductRepository()) {
        self.productRepository = productRepository
    }
    
    func fetchPrdouctDetail(
        of productID: Int) -> Observable<ProductDetail> {
        return self.productRepository.fetchProductDetail(of: productID)
    }
    
    func isValidInput(
        name: Observable<String?>,
        price: Observable<String?>,
        stock: Observable<String?>,
        description: Observable<String?>,
        discountedPrice: Observable<String?> ) -> Observable<(ProductInputChecker.ValidationResult, String?)> {
        let isValdName = self.inputChecker.isValid(name: name)
        let isValidPrice = self.inputChecker.isValid(price: price)
        let isValidStock = self.inputChecker.isValid(stock: stock)
        let isValidDescription = self.inputChecker.isValid(description: description)
        let isValidDiscountedPrice = inputChecker.isValid(discountedPrice: discountedPrice, price: price)
        
        return Observable.zip(isValdName, isValidPrice, isValidStock, isValidDescription, isValidDiscountedPrice) { self.inputChecker.validationResultOf( isValidName: $0, isValidPrice: $1, isValidStock: $2, isValidDescription: $3, isValidDiscountedPrice: $4) }
    }
    
    func requestProductEdit(
        eidtProductInfo: EditProductInfo?,
        productID: Int?) -> Observable<ProductDetail> {
        return self.createEditRequest(with: eidtProductInfo, productID: productID)
            .flatMap{ request in
                self.productRepository.requestProductEdit(with: request) }
    }
    
    func createEditProductInfo(
        name: String?,
        description: String?,
        price: String?,
        currencyIndex: Int,
        discountedPrice: String?,
        stock: String?,
        secret: String) -> EditProductInfo? {
        guard let name = name,
              let description = description,
              let price = price,
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
                               currency: currency.toEntity(),
                               discountedPrice: ((discountedPrice ?? "0") as NSString).doubleValue,
                               stock: (stock as NSString).integerValue,
                               secret: secret)
    }
    
    private func createEditRequest(
        with productInfo: EditProductInfo?,
        productID: Int?) -> Observable<ProductEditRequest> {
        let editRequest = Observable<ProductEditRequest>.create{ observer in
            guard let id = productID,
                  let productInfo = productInfo else {
                observer.onError(EditProductUsecaseError.requestCreationFail)
                return Disposables.create()
            }
            let request = ProductEditRequest(
                identifier: Bundle.main.sellerIdentifier,
                productID: id,
                productInfo: productInfo)
            observer.onNext(request)
            return Disposables.create()
        }
        return editRequest
    }
    
    enum EditProductUsecaseError: Error {
        case requestCreationFail
    }
    
}
