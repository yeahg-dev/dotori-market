//
//  ProductRegisterationRecorder.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/22.
//

import Foundation

import RealmSwift

struct ProductRegisterationRecorder {
    
    let realm = try! Realm()
    
    func recordProductRegistraion(productID: Int) {
        let productToRegister = RegisterdProduct()
        productToRegister.id = Int64(productID)
        
        try? realm.write {
            realm.add(productToRegister)
        }
    }
    
    func readRegisterdProductIDs() -> [Int] {
        let products = realm.objects(RegisterdProduct.self)

        return Array(products).compactMap{ $0.id }.map{ Int($0) }
    }
    
}
