//
//  MarketProductRepository.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/26.
//

import Foundation

import RxSwift

struct MarketProductRepository: ProductRepository {
    
    private let service: MarketAPIService
    
    init(service: MarketAPIService = MarketAPIService()) {
        self.service = service
    }
    
    func fetchProductListPage(
        of page: Int,
        itemsPerPage: Int,
        searchValue: String?)
    -> Observable<ProductListPage>
    {
        let request = ProductsListPageRequest(
            pageNo: page,
            itemsPerPage: itemsPerPage,
            searchValue: searchValue)
        return self.service.requestRx(request)
            .map{ data -> ProductsListPageResponse in
                guard let response: ProductsListPageResponse = JSONCodable().decode(
                    from: data,
                    dateFormat: .short) else {
                    print("ProductList data parsing failed")
                    throw MarketProductRepositorError.parsingFail }
                return response }
            .map{ $0.toDomain() }
    }
    
    func fetchProductDetail(of productID: Int) -> Observable<ProductDetail> {
        let request = ProductDetailRequest(productID: productID)
        
        return self.service.requestRx(request)
            .map{ data -> ProductDetailResponse in
                guard let response: ProductDetailResponse = JSONCodable().decode(
                    from: data,
                    dateFormat: .short) else {
                    print("ProdcutDetail data parsing failed")
                    throw MarketProductRepositorError.parsingFail }
                return response }
            .map{ $0.toDomain() }
    }
    
    func requestProductEdit(
        with request: ProductEditRequest)
    -> Observable<ProductDetail>
    {
        return self.service.requestRx(request)
            .map{ data -> ProductDetailResponse in
                guard let response: ProductDetailResponse = JSONCodable().decode(
                    from: data,
                    dateFormat: .short) else {
                    throw MarketProductRepositorError.parsingFail }
                return response }
            .map{ $0.toDomain() }
    }
    
    func requestProductRegistration(with request: ProductRegistrationRequest) -> Observable<ProductDetail> {
        return self.service.requestRx(request)
            .map{ data -> ProductDetailResponse in
                if let response: ProductDetailResponse = JSONCodable().decode(
                    from: data,
                    dateFormat: .long) {
                    return response
                } else {
                    print("Product Detail parsing error failed")
                    throw MarketProductRepositorError.parsingFail } }
            .map{ $0.toDomain() }
    }
    
    enum MarketProductRepositorError: Error {
        
        case parsingFail
    }
    
}
