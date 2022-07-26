//
//  DotoriMarket++Bundle.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/26.
//

import Foundation

extension Bundle {
    
    var sellerIdentifier: String {
        guard let filePath = self.path(forResource: "SellerInfo", ofType: "plist") else {
            return ""
        }
        
        guard let resource = NSDictionary(contentsOfFile: filePath) else {
            return ""
        }
        
        guard let key = resource["identifier"] as? String else {
            fatalError("SellerInfo에 identifier를 지정해주세요")
        }
        return key
    }
}
