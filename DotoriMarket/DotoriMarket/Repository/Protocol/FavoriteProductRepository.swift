//
//  FavoriteProductRepository.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/27.
//

import Foundation

import RealmSwift
import RxSwift

protocol FavoriteProductRepository {
    
    func createFavoriteProduct(productID: Int)
    
    func deleteFavoriteProduct(productID: Int)
    
    func fetchFavoriteProductIDs() -> Observable<[Int]>
    
    func fetchIsLikeProduct(productID: Int) -> Observable<Bool>
    
}
