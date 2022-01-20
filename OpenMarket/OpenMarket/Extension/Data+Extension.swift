//
//  Data+Extension.swift
//  OpenMarket
//
//  Created by lily on 2022/01/07.
//

import Foundation

extension Data {
    
    mutating func append(_ string: String, using encodingStyle: String.Encoding) {
        guard let data = string.data(using: encodingStyle) else {
            return
        }
        self.append(data)
    }
}
