//
//  RegisteredProductRepository.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/28.
//

import Foundation

import RealmSwift

protocol RegisteredProductRepository {
    
    func createRegisteredProduct(productID: Int)
    
    func fetchRegisteredProductIDs() -> [Int]
    
}


protocol RealmRegisteredProductRepository: RegisteredProductRepository {
    
    var realm: Realm { get set }
    
}
