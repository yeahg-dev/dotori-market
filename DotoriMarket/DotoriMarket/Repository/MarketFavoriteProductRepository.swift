//
//  MarketFavoriteProductRepository.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/27.
//

import Foundation

import RealmSwift
import RxSwift

struct MarketFavoriteProductRepository: FavoriteProductRepository {
    
    private let realm = RealmStorage.defaultRealm!
    private let dispatchQueue = RealmStorage.DispatchQueueRealm!

    func createFavoriteProduct(productID: Int) {
        dispatchQueue.async {
            let favoriteProduct = LikeProduct()
            favoriteProduct.id = Int64(productID)
            favoriteProduct.isLike = true
            
            try? realm.write {
                realm.add(favoriteProduct)
            }
        }
    }
    
    func deleteFavoriteProduct(productID: Int) {
        dispatchQueue.async {
            let favoriteProducts = realm.objects(LikeProduct.self)
            
            let favoriteProductResult = favoriteProducts.where { $0.id == Int64(productID) }
            guard let favoriteProduct = Array(favoriteProductResult)[safe: 0] else {
                return
            }
          
            try? realm.write {
                realm.delete(favoriteProduct)
            }
        }
    }
  
    func fetchFavoriteProductIDs() -> Observable<[Int]> {
        let observable = Observable<[Int]>.create{ observer in
            dispatchQueue.async {
                let products = realm.objects(LikeProduct.self)
                let favoriteProducts = Array(products.filter("isLike == YES"))
                    .map{$0.toDomain()}
                    .compactMap{ $0.id }
                    .map{ Int($0) }
                observer.onNext(favoriteProducts)
            }
            return Disposables.create()
        }
        return observable
    }

    func fetchIsLikeProduct(productID: Int) -> Observable<Bool> {
        let observable = Observable<Bool>.create{ observer in
            dispatchQueue.async {
                let products = realm.objects(LikeProduct.self)
                
                guard products.count > 0,
                      let product = Array(products.where { $0.id == Int64(productID) })[safe: 0]else {
                    observer.onNext(false)
                    return
                }
                
                let favoriteProduct = product.toDomain()
                observer.onNext(favoriteProduct.isLike)
               
            }
            return Disposables.create()
        }
        return observable
    }
    
}
