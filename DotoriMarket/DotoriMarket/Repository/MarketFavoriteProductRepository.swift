//
//  MarketFavoriteProductRepository.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/27.
//

import Foundation

import RealmSwift

struct MarketFavoriteProductRepository: RealmFavoriteProductRepository {
    
    var realm: Realm
    
    init(realm: Realm = try! Realm()) {
        self.realm = realm
    }
    
    func createFavoriteProduct(productID: Int) {
        let favoriteProduct = LikeProduct()
        favoriteProduct.id = Int64(productID)
        favoriteProduct.isLike = true
        
        try? realm.write {
            realm.add(favoriteProduct)
        }
    }
    
    func deletFavoriteProduct(productID: Int) {
        let favoriteProducts = realm.objects(LikeProduct.self)
        
        let favoriteProductResult = favoriteProducts.where { $0.id == Int64(productID) }
        guard let favoriteProduct = Array(favoriteProductResult)[safe: 0] else {
            return
        }
      
        try? realm.write {
            realm.delete(favoriteProduct)
        }
    }
    
    func fetchFavoriteProductIDs() -> [Int] {
        let products = realm.objects(LikeProduct.self)

        let favoriteProducts = Array(products.filter("isLike == YES"))

        return favoriteProducts.compactMap{ $0.id }.map{ Int($0) }
    }
    
    func fetchIsLikeProduct(productID: Int) -> Bool {
        let products = realm.objects(LikeProduct.self)
        
        guard products.count > 1 else {
            return false
        }
        
        let product = Array(products.where { $0.id == Int64(productID) })[safe: 0]
        
        return product?.isLike ?? false
    }
    
}
