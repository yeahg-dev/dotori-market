//
//  MarketRegisteredProductRepository.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/28.
//

import Foundation

import RealmSwift
import RxSwift

struct MarketRegisteredProductRepository: RegisteredProductRepository {
    
    private let realm = RealmStorage.defaultRealm!
    private let dispatchQueue = RealmStorage.DispatchQueueRealm!
    
    func createRegisteredProduct(productID: Int) {
        dispatchQueue.async {
            let productToRegister = RegisterdProduct()
            productToRegister.id = Int64(productID)
            
            try? realm.write {
                realm.add(productToRegister)
            }
        }
    }
    
    func fetchRegisteredProductIDs() -> Observable<[Int]> {
        let observable = Observable<[Int]>.create{ observer in
            dispatchQueue.async {
                let products = realm.objects(RegisterdProduct.self)
                let registeredProductIDs = Array(products)
                    .compactMap{ $0.id }
                    .map{ Int($0) }
                observer.onNext(registeredProductIDs)
            }
            return Disposables.create()
        }
        return observable
    }
    
}
