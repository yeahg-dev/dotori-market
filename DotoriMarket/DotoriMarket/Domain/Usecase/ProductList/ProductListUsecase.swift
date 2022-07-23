//
//  ProductListUsecase.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/20.
//

import Foundation

import RxSwift

protocol ProductListUsecase {
    
    var service: APIServcie { get }
    
    func fetchPrdoucts(
        pageNo: Int,
        itemsPerPage: Int) -> Observable<([ProductViewModel], Bool)>
    
    func fetchNavigationBarComponent() -> Observable<NavigationBarComponent>
    
}
