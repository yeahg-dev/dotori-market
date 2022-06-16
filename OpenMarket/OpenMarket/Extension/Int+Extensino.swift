//
//  Int+Extensino.swift
//  OpenMarket
//
//  Created by 1 on 2022/06/16.
//

import Foundation

extension Int {
    
    private static let numberFormatter = NumberFormatter()
    
    var decimalFormatted: String {
        Self.numberFormatter.numberStyle = .decimal
        let result = Self.numberFormatter.string(for: self) ?? self.description
        return result
    }
}
