//
//  MarketRegisteredProductRepository.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/28.
//

import Foundation

import RealmSwift

struct MarketRegisteredProductRepository: RegisteredProductRepository {
    
    var realm: Realm
    
    init(realm: Realm = try! Realm()) {
        self.realm = realm
    }
    
    func createRegisteredProduct(productID: Int) {
        let productToRegister = RegisterdProduct()
        productToRegister.id = Int64(productID)
        
        try? realm.write {
            realm.add(productToRegister)
        }
    }
    
    func fetchRegisteredProductIDs() -> [Int] {
        let products = realm.objects(RegisterdProduct.self)

        return Array(products).compactMap{ $0.id }.map{ Int($0) }
    }
    
}
