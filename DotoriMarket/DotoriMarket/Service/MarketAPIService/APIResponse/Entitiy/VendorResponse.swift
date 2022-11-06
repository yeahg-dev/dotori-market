//
//  VendorResponse.swift
//  DotoriMarket
//
//  Created by lily on 2022/01/05.
//

import Foundation

struct VendorResponse: Codable {
    
    let name: String
    let id: Int
    
    private enum CodingKeys: String, CodingKey {

        case name, id
    }
}
