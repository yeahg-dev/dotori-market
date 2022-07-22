//
//  TabCoordinator.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/18.
//

import UIKit

protocol TabCoordinator: Coordinator {
    
}

extension TabCoordinator {
    
    func tabViewController() -> UINavigationController {
        self.start()
        return self.navigationController
    }
    
}
