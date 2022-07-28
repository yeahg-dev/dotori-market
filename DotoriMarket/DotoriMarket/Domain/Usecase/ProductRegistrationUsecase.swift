//
//  ProductRegistrationUsecase.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/26.
//

import Foundation

import RxSwift

struct ProductRegistrationUsecase {
    
    private let productRepository: ProductRepository
    private let registredProductRepository: RegisteredProductRepository
    private let inputChecker = ProductInputChecker()
 
    init(productRepository: MarketProductRepository = MarketProductRepository(),
         registredProductRepository: RegisteredProductRepository = MarketRegisteredProductRepository()) {
        self.productRepository = productRepository
        self.registredProductRepository = registredProductRepository
    }

    func isValidInput(
        image: Observable<[(CellType, Data)]>,
        name: Observable<String?>,
        price: Observable<String?>,
        stock: Observable<String?>,
        description: Observable<String?>,
        discountedPrice: Observable<String?> )
    -> Observable<(ProductInputChecker.ValidationResult, String?)> {
        let isValidImage = self.inputChecker.isVald(image: image)
        let isValdName = self.inputChecker.isValid(name: name)
        let isValidPrice = self.inputChecker.isValid(price: price)
        let isValidStock = self.inputChecker.isValid(stock: stock)
        let isValidDescription = self.inputChecker.isValid(
            description: description)
        let isValidDiscountedPrice = self.inputChecker.isValid(
            discountedPrice: discountedPrice,
            price: price)
        
        return Observable.combineLatest(isValidImage, isValdName, isValidPrice,
            isValidStock, isValidDescription, isValidDiscountedPrice) {
            self.inputChecker.validationResultOf(
                isValidImage: $0,
                isValidName: $1,
                isValidPrice: $2,
                isValidStock: $3,
                isValidDescription: $4,
                isValidDiscountedPrice: $5) }
    }
    
    func requestProductRegisteration(
            name: Observable<String?>,
            price: Observable<String?>,
            currency: Observable<Int>,
            discountedPrice: Observable<String?>,
            stock: Observable<String?>,
            description: Observable<String?>,
            secret: Observable<String>,
            image: Observable<[(CellType, Data)]>) -> Observable<ProductDetail> {
        return Observable.combineLatest(name, price, currency, discountedPrice,
                                        stock, description, secret,image,
            resultSelector: { (name, price, currency, discountedPrice, stock,
                descritpion, secret, image) -> ProductRegistrationRequest in
               return self.createRegisterationRequest(
                name: name,
                price: price,
                currency: currency,
                discountedPrice: discountedPrice,
                stock: stock,
                description: descritpion,
                secret: secret,
                image: image) })
            .flatMap { request in
                self.request(reqeust: request) }
            .do{ productDetail in
                self.registredProductRepository.createRegisteredProduct(
                    productID: productDetail.id) }

    }
    
    private func createRegisterationRequest(
        name: String?,
        price: String?,
        currency: Int,
        discountedPrice: String?,
        stock: String?,
        description: String?,
        secret: String,
        image: [(CellType, Data)]) -> ProductRegistrationRequest {
        let newProductInfo = self.createNewProductInfo(
            name: name,
            price: price,
            currency: currency,
            discountedPrice: discountedPrice,
            stock: stock,
            description: description,
            secret: secret)
        let imageDatas = image.filter{ image in image.0 == .productImageCell }
            .map{ image in image.1 }
        let imageFiles = imageDatas.imageFile(fileName: newProductInfo.name)
        
        return ProductRegistrationRequest(
            identifier: Bundle.main.sellerIdentifier,
            params: newProductInfo,
            images: imageFiles)
    }
    
    private func createNewProductInfo(name: String?,
                                      price: String?,
                                      currency: Int,
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
    
    private func request(
        reqeust: ProductRegistrationRequest) -> Observable<ProductDetail> {
        self.productRepository.requestProductRegisteration(with: reqeust)
    }
    
}
