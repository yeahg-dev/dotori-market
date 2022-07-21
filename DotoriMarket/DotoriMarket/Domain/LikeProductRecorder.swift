//
//  LikeProductRecorder.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/21.
//

import Foundation

import RealmSwift

struct LikeProductRecorder {
    
    let realm = try! Realm()
    
    func recordLikeProduct(producutID: Int) {
        let likeProduct = LikeProduct(id: producutID, isLike: true)
        
        try? realm.write {
            realm.add(likeProduct)
        }
    }
    
    func recordUnlikeProduct(productID: Int) {
        let unlikeProduct = LikeProduct(id: productID, isLike: false)
        
        try? realm.write {
            realm.add(unlikeProduct)
        }
    }
    
    func readlikeProductIDs() -> [Int] {
        let products = realm.objects(LikeProduct.self)

        let likedProducts = Array(products.filter("isLike == true"))
        
        return likedProducts.map{ $0.id }
    }
    
    func readIsLike(productID: Int) -> Bool {
        let products = realm.objects(LikeProduct.self)
        
        let product = Array(products.filter("id == %@")).first
        
        return product?.isLike ?? false
    }
    
}
