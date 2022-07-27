//
//  ProductRegisterationUsecase.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/26.
//

import Foundation

import RxSwift

struct ProductRegisterationUsecase {
    
    private let productRepository: ProductRepository
    private let inputChecker = ProductInputChecker()
    
    init(productRepository: MarketProductRepository = MarketProductRepository()) {
        self.productRepository = productRepository
    }
    
    func requestRegisterProduct(reqeust: ProductRegistrationRequest) -> Observable<ProductDetail> {
        self.productRepository.requestProductRegisteration(with: reqeust)
    }
    
    func isValidInput(
        image: Observable<[(CellType, Data)]>,
        name: Observable<String?>,
        price: Observable<String?>,
        stock: Observable<String?>,
        description: Observable<String?>,
        discountedPrice: Observable<String?> ) -> Observable<(ProductInputChecker.ValidationResult, String?)> {
        let isValidImage = self.inputChecker.isVald(image: image)
        let isValdName = self.inputChecker.isValid(name: name)
        let isValidPrice = self.inputChecker.isValid(price: price)
        let isValidStock = self.inputChecker.isValid(stock: stock)
        let isValidDescription = self.inputChecker.isValid(description: description)
        let isValidDiscountedPrice = self.inputChecker.isValid(discountedPrice: discountedPrice, price: price)
        
        return Observable.combineLatest(isValidImage, isValdName, isValidPrice, isValidStock, isValidDescription, isValidDiscountedPrice) { self.inputChecker.validationResultOf(isValidImage: $0, isValidName: $1, isValidPrice: $2, isValidStock: $3, isValidDescription: $4, isValidDiscountedPrice: $5) }
    }
    
    func createRegistrationRequest(
        with productInfo: NewProductInfo,
        productImages: [(CellType, Data)]) -> ProductRegistrationRequest {
        let imageDatas = productImages.filter{ image in image.0 == .productImageCell }
            .map{ image in image.1 }
        let imageFiles = imageDatas.imageFile(fileName: productInfo.name)
        let registrationRequest = ProductRegistrationRequest(identifier: Bundle.main.sellerIdentifier,
                                                             params: productInfo,
                                                             images: imageFiles)
        return registrationRequest
    }
    
    func createNewProductInfo(name: String?,
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
