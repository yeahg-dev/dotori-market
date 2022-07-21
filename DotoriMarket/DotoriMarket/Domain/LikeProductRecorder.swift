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
    
    func recordLikeProduct(productID: Int) {
        let likeProduct = LikeProduct()
        likeProduct.id = Int64(productID)
        likeProduct.isLike = true
        
        try? realm.write {
            realm.add(likeProduct)
        }
    }
    
    func recordUnlikeProduct(productID: Int) {
        let products = realm.objects(LikeProduct.self)
        let likedProducts = products.where { $0.id == Int64(productID) }[0]
      
        try? realm.write {
            likedProducts.isLike = false
        }
    }
    
    func readlikeProductIDs() -> [Int] {
        let products = realm.objects(LikeProduct.self)

        let likedProducts = Array(products.filter("isLike == YES"))
        
        return likedProducts.compactMap{ $0.id }.map{ Int($0) }
    }
    
    func readIsLike(productID: Int) -> Bool {
        let products = realm.objects(LikeProduct.self)
        
        let product = Array(products.where { $0.id == Int64(productID) }).first
        
        return product?.isLike ?? false
    }
    
}
