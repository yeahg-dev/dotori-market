//
//  LikeProduct.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/21.
//

import Foundation

import RealmSwift

final class LikeProduct: Object {
    
    @objc dynamic var id: Int64 = 0
    @objc dynamic var isLike: Bool = false
    @objc dynamic var likedDate: Date = Date()
    
}

extension LikeProduct {
    
    func toDomain() -> FavoriteProduct {
        return FavoriteProduct(
            id: Int(self.id),
            isLike: self.isLike,
            lastModifiedDate: self.likedDate)
    }
    
}
