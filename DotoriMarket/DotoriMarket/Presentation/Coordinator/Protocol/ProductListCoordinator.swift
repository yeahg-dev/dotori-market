//
//  ProductListCoordinator.swift
//  DotoriMarket
//
//  Created by Moon Yeji on 2022/11/15.
//

import UIKit

protocol ProductListCoordinator: Coordinator {
    
    func rightNavigationItemDidTapped(from: UIViewController)
    func cellDidTapped(of productID: Int)
    
}
