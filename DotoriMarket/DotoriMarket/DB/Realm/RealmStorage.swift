//
//  RealmStorage.swift
//  DotoriMarket
//
//  Created by Moon Yeji on 2022/08/21.
//

import Foundation

import RealmSwift

final class RealmStorage {
    
    static var defaultRealm: Realm!
    static var DispatchQueueRealm: DispatchQueue!
    
    static func configureDefaultRealm() {
        DispatchQueueRealm = DispatchQueue.main
        RealmStorage.defaultRealm = try? Realm()
    }
    
}
