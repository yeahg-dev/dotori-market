//
//  LikeProduct.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/21.
//

import Foundation

import RealmSwift

class LikeProduct: Object {
    
    @objc dynamic var id: Int64 = 0
    @objc dynamic var isLike: Bool = false
    @objc dynamic var likedDate: Date = Date()
 
}
