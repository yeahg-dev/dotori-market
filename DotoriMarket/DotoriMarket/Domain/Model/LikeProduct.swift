//
//  LikeProduct.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/21.
//

import Foundation

import RealmSwift

class LikeProduct: Object {
    
    var id: Int
    var isLike: Bool
    
    init(id: Int, isLike: Bool) {
        self.id = id
        self.isLike = isLike
    }
    
}
