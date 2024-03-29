//
//  ProductRepository.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/26.
//

import Foundation

import RxSwift

protocol ProductRepository {
    
    func fetchProductListPage(
        of page: Int,
        itemsPerPage: Int,
        searchValue: String?)
    -> Observable<ProductListPage>
    
    func fetchProductDetail(
        of productID: Int)
    -> Observable<ProductDetail>
    
    func requestProductEdit(
        with request: ProductEditRequest)
    -> Observable<ProductDetail>
    
    func requestProductRegistration(
        with request: ProductRegistrationRequest)
    -> Observable<ProductDetail>

}
