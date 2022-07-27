//
//  FavoriteProductRepository.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/27.
//

import Foundation

protocol FavoriteProductRepository {
    
    func createFavoriteProduct(productID: Int)
    
    func deletFavoriteProduct(productID: Int)
    
    func fetchFavoriteProductIDs() -> [Int]
    
    func fetchIsLikeProduct(productID: Int) -> Bool
    
}
