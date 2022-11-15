//
//  Cancellable.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/08.
//

import Foundation

protocol Cancellable {
    
    func cancel()
}

extension URLSessionDataTask: Cancellable { }
