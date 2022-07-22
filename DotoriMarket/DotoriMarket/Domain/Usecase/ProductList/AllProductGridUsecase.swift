//
//  AllProductGridUsecase.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/20.
//

import Foundation

import RxSwift

class AllProductGridUsecase: AllProductListUsecase {
    
    override func fetchNavigationBarComponent() -> Observable<NavigationBarComponent> {
        return Observable.just(
            NavigationBarComponent(
                title: "상품 보기",
                rightBarButtonImageSystemName: "list.dash"))
    }
}
