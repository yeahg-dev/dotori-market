//
//  MyProduct.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/22.
//

import Foundation

import RealmSwift

class MyProduct: Object {
    
    @objc dynamic var id: Int64 = 0
    @objc dynamic var registerationDate: Date = Date()
 
}
