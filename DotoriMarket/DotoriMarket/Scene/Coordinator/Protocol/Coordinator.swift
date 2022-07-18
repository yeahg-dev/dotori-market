//
//  Coordinator.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/18.
//

import UIKit

protocol Coordinator {
    
    var childCoordinator: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
    
}
