//
//  Double+Extension.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/14.
//

import Foundation

extension Double {
    
    private static let numberFormatter = NumberFormatter()
    
    var stringFormmated: String {
        return String(format: "%.0f", self)
    }
    
    var decimalFormatted: String {
        Self.numberFormatter.numberStyle = .decimal
        let result = Self.numberFormatter.string(for: self) ?? self.description
        return result
    }
    
    var formattedPercent: String {
        Self.numberFormatter.numberStyle = .percent
        let fortmatted = Self.numberFormatter.string(for: self) ?? self.description
        return fortmatted
    }
}
