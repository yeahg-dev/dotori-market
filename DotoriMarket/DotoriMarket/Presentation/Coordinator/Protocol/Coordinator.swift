//
//  Coordinator.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/18.
//

import UIKit

protocol Coordinator: AnyObject {
    
    var childCoordinator: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
    
}

extension Coordinator {
    
    func childDidFinish(_ child: Coordinator?){
        guard let child = child else {
            return
        }

        for (index, coordinator) in self.childCoordinator.enumerated() {
            if coordinator === child {
                self.childCoordinator.remove(at: index)
                break
            }
        }
    }
    
}
