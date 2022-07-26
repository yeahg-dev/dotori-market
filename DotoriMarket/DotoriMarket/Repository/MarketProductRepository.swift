//
//  MarketProductRepository.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/26.
//

import Foundation

import RxSwift

final class MarketProductRepository: ProductRepository {

    private let service: MarketAPIService
    
    init(service: MarketAPIService = MarketAPIService()) {
        self.service = service
    }
    
    func fetchProductListPage(of page: Int, itemsPerPage: Int) -> Observable<ProductListPage> {
        let request = ProductsListPageRequest(pageNo: page, itemsPerPage: itemsPerPage)
        return self.service.requestRx(request)
            .map{ data -> ProductsListPageResponse? in
                guard let response: ProductsListPageResponse = JSONCodable().decode(from: data) else { return nil }
                return response }
            .filterNil()
            .map{ $0.toDomain() }
    }
    
    func fetchProductDetail(of productID: Int) -> Observable<ProductDetail> {
        let request = ProductDetailRequest(productID: productID)
           
        return self.service.requestRx(request)
            .map{ data -> ProductDetailResponse? in
                guard let response: ProductDetailResponse = JSONCodable().decode(from: data) else { return nil }
                return response }
            .filterNil()
            .map{ $0.toDomain() }
    }

    func requestProductEdit(with request: ProductEditRequest) -> Observable<ProductDetail> {
        return self.service.requestRx(request)
            .map{ data -> ProductDetailResponse? in
            guard let response: ProductDetailResponse = JSONCodable().decode(from: data) else { return nil }
            return response }
            .filterNil()
            .map{ $0.toDomain() }
    }
    
    func requestProductRegisteration(with request: ProductRegistrationRequest) -> Observable<ProductDetail> {
        return self.service.requestRx(request)
            .map{ data -> ProductDetailResponse? in
            guard let response: ProductDetailResponse = JSONCodable().decode(from: data) else { return nil }
            return response }
            .filterNil()
            .map{ $0.toDomain() }
    }
    
}
