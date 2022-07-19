//
//  TabCoordinator.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/18.
//

import UIKit

protocol TabCoordinator: Coordinator {
    
    func tabViewController() -> UINavigationController
    
}