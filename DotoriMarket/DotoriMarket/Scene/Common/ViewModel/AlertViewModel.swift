//
//  AlertViewModel.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/10.
//

import Foundation

protocol AlertViewModel {
    
    var title: String? { get }
    var message: String? { get }
    var actionTitle: String? { get }
}
