//
//  RegisteredProductRepository.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/28.
//

import Foundation

import RealmSwift
import RxSwift

protocol RegisteredProductRepository {
    
    func createRegisteredProduct(productID: Int)
    
    func fetchRegisteredProductIDs() -> Observable<[Int]>
    
}
