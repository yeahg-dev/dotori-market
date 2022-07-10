//
//  ProductEditSceneViewModel.swift
//  OpenMarket
//
//  Created by 1 on 2022/06/26.
//

import Foundation

import RxSwift
import RxCocoa

final class ProductEditSceneViewModel {
    
    private var APIService: APIServcie
    private let sellerIdentifier = "c4dedd67-71fc-11ec-abfa-fd97ecfece87"
    private var productID: Int?
    
    init(APIService: APIServcie) {
        self.APIService = APIService
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
            .do(onNext: { productID in
                self.productID = productID })
            .map{ ProductDetailRequest(productID: $0) }
            .flatMap{ request -> Observable<ProductDetailResponse> in
                self.APIService.requestRx(request) }
            .map{ $0.toDomain() }
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
        
        let isValidName = self.validate(name: input.productName.asObservable())
        let isValidPrice = self.validate(price: input.productPrice.asObservable())
        let isValidStock = self.validate(stock: input.productStock.asObservable())
        let isvalidDescription = self.validate(description: input.productDescription.asObservable())
        
        let requireSecret = input.doneDidTapped
            .flatMap{ _ in
                Observable.zip(isValidName, isValidPrice, isValidStock, isvalidDescription,
                               resultSelector: { self.validate(isValidName: $0, isValidPrice: $1, isValidStock: $2, isValidDescription: $3) }) }
            .filter{ (result, descritpion) in result == .success }
            .map{ _ in RequireSecretAlertViewModel() }
            .asDriver(onErrorJustReturn: ErrorAlertViewModel() as AlertViewModel)
    
        let validationFailureAlert = input.doneDidTapped
            .flatMap{ _ in
                Observable.zip(isValidName, isValidPrice, isValidStock, isvalidDescription,
                               resultSelector: { self.validate(isValidName: $0, isValidPrice: $1, isValidStock: $2, isValidDescription: $3) }) }
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
            .flatMap{ request in self.APIService.requestRx(request) }
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

// MARK: - AlertViewModel

extension ProductEditSceneViewModel {
    
    struct RequireSecretAlertViewModel: AlertViewModel {
        
        var title: String? = "판매자 비밀번호를 입력해주세요"
        var message: String?
        var actionTitle: String?  = "수정"
    }
   
    struct RequestFailureAlertViewModel: AlertViewModel {
        
        var title: String? = "수정에 실패했습니다"
        var message: String? = "다시 시도 해주세요"
        var actionTitle: String? = "확인"
    }
    
    struct ValidationFailureAlertViewModel: AlertViewModel {
        
        var title: String?
        var message: String? = "다시 시도 해주세요"
        var actionTitle: String? = "확인"
    }

}

// MARK: - Input Validation

extension ProductEditSceneViewModel {

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
                .filter{ !$0.isEmpty }
                .reduce("") { partialResult, category in
                    partialResult.isEmpty ? category : "\(partialResult), \(category)" }
            
            if isValidDescription == false || isValidStock == false {
                return "\(description)는 필수 입력 항목이에요"
            } else {
                return "\(description)은 필수 입력 항목이에요"
            }
        }
    }
    
    private func validate(name: Observable<String?>) -> Observable<Bool> {
        return name.map{ name -> Bool in
            guard let name = name else { return false }
            return name.isEmpty ? false : true }
    }
    
    private func validate(price: Observable<String?>) -> Observable<Bool> {
        return price.map{ price -> Bool in
            guard let price = price else { return false }
            return price.isEmpty ? false : true }
    }
    
    private func validate(stock: Observable<String?>) -> Observable<Bool> {
        return stock.map{ stock -> Bool in
            guard let stock = stock else { return false }
            return stock.isEmpty ? false : true }
    }
    
    private func validate(description: Observable<String?>) -> Observable<Bool> {
        return description.map{ description -> Bool in
            guard let text = description else { return false }
            if text == MarketCommon.descriptionTextViewPlaceHolder.rawValue { return false }
            return text.count >= 10 && text.count <= 1000 ? true : false }
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
                               currency: currency.toEntity(),
                               discountedPrice: (discountedPrice as NSString).doubleValue,
                               stock: (stock as NSString).integerValue,
                               secret: secret)
    }

}
