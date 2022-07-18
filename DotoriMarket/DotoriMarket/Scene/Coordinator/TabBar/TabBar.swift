//
//  TabBar.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/18.
//

import UIKit

enum TabBar {
    
    case productList
    case myDotori
    case liked
    
    func components() -> TabBarComponent {
        switch self {
        case .productList:
           return ProductListTabBar()
        case .myDotori:
            return ProductListTabBar()
        case .liked:
            return ProductListTabBar()
        }
    }
    
}
