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
    
    private let usecase: ProductEditUsecase
    private let productInputChecker = ProductInputChecker()
    private var productID: Int?
    
    init(usecase: ProductEditUsecase) {
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
            .do(onNext: { self.productID = $0.id })
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
        
        let isValidInput = input.doneDidTapped
            .flatMap { self.usecase.isValidInput(
                name: input.productName.asObservable(),
                price: input.productPrice.asObservable(),
                stock: input.productStock.asObservable(),
                description: input.productDescription.asObservable(),
                discountedPrice: input.productDiscountedPrice.asObservable())
            }
        
        let requireSecret = isValidInput
            .filter{ (result, descritpion) in result == .success }
            .map{ _ in RequireSecretAlertViewModel() }
            .asDriver(onErrorJustReturn: ErrorAlertViewModel() as AlertViewModel)
        
        let validationFailureAlert = isValidInput
            .filter{ (result, descritpion) in result == .failure }
            .map{ (result, description) in description }
            .map { ValidationFailureAlertViewModel(title: $0)
                as AlertViewModel }
            .asDriver(onErrorJustReturn: ErrorAlertViewModel() as AlertViewModel)
        
        let registrationFailureAlert = PublishSubject<AlertViewModel>()
        
        let registerationResponse = input.didReceiveSecret
            .flatMap{ secret in
                return Observable.combineLatest(
                    input.productName.asObservable(),
                    input.productPrice.asObservable(),
                    input.productDiscountedPrice.asObservable(),
                    input.productCurrencyIndex.asObservable(),
                    input.productStock.asObservable(),
                    input.productDescription.asObservable(),
                    Observable.just(secret),
                    resultSelector: { (name, price, discountedPrice, currency, stock, descritpion, secret) -> EditProductInfo? in
                        return self.usecase.createEditProductInfo(
                            name: name,
                            description: descritpion,
                            price: price,
                            currencyIndex: currency,
                            discountedPrice: discountedPrice,
                            stock: stock,
                            secret: secret) }) }
            .flatMap({ editInfo in
                self.usecase.requestProductEdit(
                    eidtProductInfo: editInfo,
                    productID: self.productID) })
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
