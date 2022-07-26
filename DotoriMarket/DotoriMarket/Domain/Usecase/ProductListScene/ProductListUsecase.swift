//
//  ProductListUsecase.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/20.
//

import Foundation

import RxSwift

protocol ProductListUsecase {
    
    var productRepository: ProductRepository { get }
     
    func fetchPrdoucts(
        pageNo: Int,
        itemsPerPage: Int) -> Observable<([ProductViewModel], Bool)>
    
    func fetchNavigationBarComponent() -> Observable<NavigationBarComponent>
    
}
