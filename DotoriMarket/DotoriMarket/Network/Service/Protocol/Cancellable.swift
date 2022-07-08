//
//  Cancellable.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/08.
//

import Foundation

protocol Cancellable {
    
    func cancel()
}

extension URLSessionDataTask: Cancellable { }
