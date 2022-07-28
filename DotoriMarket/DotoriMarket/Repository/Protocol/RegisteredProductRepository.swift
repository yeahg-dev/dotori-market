//
//  RegisteredProductRepository.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/28.
//

import Foundation

protocol RegisteredProductRepository {
    
    func createRegisteredProduct(productID: Int)
    
    func fetchRegisteredProductIDs() -> [Int]
    
}
