//
//  Array+Extension.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/18.
//

import Foundation

extension Array {
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        
        switch indices.contains(index) {
        case true:
            return self[index]
        case false:
            return nil
        }
    }
}
