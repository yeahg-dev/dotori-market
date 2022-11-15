//
//  AllProductGridUsecase.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/20.
//

import Foundation

import RxSwift

final class AllProductGridUsecase: AllProductListUsecase {
    
    override func fetchNavigationBarComponent()
    -> Observable<NavigationBarComponentViewModel>
    {
        return Observable.just(
            NavigationBarComponentViewModel(
                title: "상품 보기",
                rightBarButtonImageSystemName: "list.dash"))
    }
}
