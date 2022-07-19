//
//  NSObejct+Extension.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/19.
//

import Foundation

extension NSObject {

    var className: String {
        return String(describing: type(of: self))
    }

    class var className: String {
        return String(describing: self)
    }

}
