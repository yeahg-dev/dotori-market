//
//  Vendor.swift
//  OpenMarket
//
//  Created by lily on 2022/01/05.
//

import Foundation

struct Vendor: Codable {
    
    let name: String
    let id: Int
    let createdAt: Date
    let issuedAt: Date
    
    private enum CodeingKeys: String, CodingKey {
        
        case createdAt = "created_at"
        case issuedAt = "issued_at"
        case name, id
    }
}
