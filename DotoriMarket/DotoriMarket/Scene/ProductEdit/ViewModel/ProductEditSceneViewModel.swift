//
//  ProductEditSceneViewModel.swift
//  DotoriMarket
//
//  Created by lily on 2022/06/26.
//

import Foundation

import RxSwift
import RxCocoa

final class ProductEditSceneViewModel {
    
    private let usecase: EditProductUsecase
    private let productInputChecker = ProductInputChecker()
    private var productID: Int?
    
    init(usecase: EditProductUsecase) {
        self.usecase = usecase
    }
    
    struct Input {
        let viewWillAppear: Observable<Int>
        let productName: ControlProperty<String?>
        let productPrice: ControlProperty<String?>
        let productDiscountedPrice: ControlProperty<String?>
        let productCurrencyIndex: ControlProperty<Int>
        let productStock: ControlProperty<String?>
        let productDescription: ControlProperty<String?>
        let doneDidTapped: ControlEvent<Void>
        let didReceiveSecret: Observable<String>
    }
    
    struct Output {
        let prdouctName: Driver<String>
        let productImagesURL: Driver<[String]>
        let productPrice: Driver<String?>
        let productDiscountedPrice: Driver<String?>
        let productCurrencyIndex: Driver<Int>
        let productStock: Driver<String>
        let productDescription: Driver<String>
        let validationFailureAlert: Driver<AlertViewModel>
        let requireSecret: Driver<AlertViewModel>
        let registrationSuccessAlert: Driver<Void>
        let registrationFailureAlert: Driver<AlertViewModel>
    }
    
    func transform(input: Input) -> Output {
        let productDetail = input.viewWillAppear
            .flatMap({ id in
                self.usecase.fetchPrdouctDetail(of: id) })
            .map{ ProductDetailEditViewModel(product: $0) }
            .share(replay: 1)
        
        let productName = productDetail.map{ $0.name }
            .asDriver(onErrorJustReturn: MarketCommon.downloadErrorPlacehodler.rawValue)
        let productPrice = productDetail.map{ $0.price }
            .asDriver(onErrorJustReturn: MarketCommon.downloadErrorPlacehodler.rawValue)
        let productDiscountedPrice = productDetail.map{ $0.discountedPrice }
            .asDriver(onErrorJustReturn: MarketCommon.downloadErrorPlacehodler.rawValue)
        let productStock = productDetail.map{ $0.stock }
            .asDriver(onErrorJustReturn: MarketCommon.downloadErrorPlacehodler.rawValue)
        let prodcutDescription = productDetail.map{ $0.description }
            .asDriver(onErrorJustReturn: MarketCommon.downloadErrorPlacehodler.rawValue)
        let productImagesURL = productDetail.map{ $0.images }.map{ $0.map{ $0.thumbnailURL }}
            .asDriver(onErrorJustReturn: [])
        let productCurrencyIndex = productDetail.map{ $0.currency }
            .map{ currency -> Int in
                switch currency {
                case .krw:
                    return 0
                case .usd:
                    return 1
                }
            }.asDriver(onErrorJustReturn: 0)
        
        let isValidName = productInputChecker.isValid(name: input.productName.asObservable())
        let isValidPrice = productInputChecker.isValid(price: input.productPrice.asObservable())
        let isValidStock = productInputChecker.isValid(stock: input.productStock.asObservable())
        let isvalidDescription = productInputChecker.isValid(description: input.productDescription.asObservable())
        let isValidDiscountedPrice = productInputChecker.isValid(discountedPrice: input.productDiscountedPrice.asObservable(), price: input.productPrice.asObservable())
        
        let requireSecret = input.doneDidTapped
            .flatMap{ _ in
                Observable.zip(isValidName, isValidPrice, isValidStock, isvalidDescription,isValidDiscountedPrice,
                               resultSelector: { self.productInputChecker.validationResultOf( isValidName: $0, isValidPrice: $1, isValidStock: $2, isValidDescription: $3, isValidDiscountedPrice: $4) }) }
            .filter{ (result, descritpion) in result == .success }
            .map{ _ in RequireSecretAlertViewModel() }
            .asDriver(onErrorJustReturn: ErrorAlertViewModel() as AlertViewModel)
        
        let validationFailureAlert = input.doneDidTapped
            .flatMap{ _ in
                Observable.zip(isValidName, isValidPrice, isValidStock, isvalidDescription,isValidDiscountedPrice,
                               resultSelector: { self.productInputChecker.validationResultOf( isValidName: $0, isValidPrice: $1, isValidStock: $2, isValidDescription: $3, isValidDiscountedPrice: $4) }) }
            .filter{ (result, descritpion) in result == .failure }
            .map{ (result, description) in description }
            .map { ValidationFailureAlertViewModel(title: $0)
                as AlertViewModel }
            .asDriver(onErrorJustReturn: ErrorAlertViewModel() as AlertViewModel)
        
        let registrationFailureAlert = PublishSubject<AlertViewModel>()
        
        let registerationResponse = input.didReceiveSecret
            .flatMap{ secret -> Observable<EditProductInfo?> in
                return Observable.combineLatest(input.productName.asObservable(), input.productPrice.asObservable(), input.productDiscountedPrice, input.productCurrencyIndex.asObservable(), input.productStock.asObservable(), input.productDescription.asObservable(), Observable.just(secret),
                                                resultSelector: { (name, price, discountedPrice, currency, stock, descritpion, secret) -> EditProductInfo? in
                    return self.createEditProductInfo(name: name, description: descritpion, price: price, currencyIndex: currency, discountedPrice: discountedPrice, stock: stock, secret: secret) }) }
            .flatMap{ productInfo in self.createEditRequest(with: productInfo) }
            .flatMap({ request in
                self.usecase.requestProductEdit(with: request) })
            .do(onError: { _ in
                registrationFailureAlert.onNext(RequestFailureAlertViewModel()) })
            .retry(when: { _ in requireSecret.asObservable() })
            .map{ _ in }
            .asDriver(onErrorJustReturn: ())
        
        return Output(prdouctName: productName,
                      productImagesURL: productImagesURL,
                      productPrice: productPrice,
                      productDiscountedPrice: productDiscountedPrice,
                      productCurrencyIndex: productCurrencyIndex,
                      productStock: productStock,
                      productDescription: prodcutDescription,
                      validationFailureAlert: validationFailureAlert,
                      requireSecret: requireSecret,
                      registrationSuccessAlert: registerationResponse,
                      registrationFailureAlert: registrationFailureAlert.asDriver(onErrorJustReturn: ErrorAlertViewModel() as AlertViewModel))
    }
}

// MARK: - API Request

extension ProductEditSceneViewModel {
    
    enum ViewModelError: Error {
        case requestCreationFail
    }
    
    private func createEditRequest(with productInfo: EditProductInfo?) -> Observable<ProductEditRequest> {
        let editRequest = Observable<ProductEditRequest>.create{ observer in
            guard let id = self.productID,
                  let productInfo = productInfo else {
                observer.onError(ViewModelError.requestCreationFail)
                return Disposables.create()
            }
            let request = ProductEditRequest(
                identifier: SellerInformation.identifier.rawValue,
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
                               currency: currency.toEntity(),
                               discountedPrice: (discountedPrice as NSString).doubleValue,
                               stock: (stock as NSString).integerValue,
                               secret: secret)
    }
    
}
