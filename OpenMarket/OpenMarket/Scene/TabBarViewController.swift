//
//  OpenMarket - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

final class TabBarViewController: UITabBarController {
    
    @IBOutlet private weak var viewSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.isHidden = true
        self.configureViewSegmentedControl()
    }
    
    @IBAction private func switchViewController(_ sender: UISegmentedControl) {
        self.selectedIndex = sender.selectedSegmentIndex
    }
    
    private func configureViewSegmentedControl() {
        self.viewSegmentedControl.setTitle("LIST", forSegmentAt: 0)
        self.viewSegmentedControl.setTitle("GRID", forSegmentAt: 1)
        self.viewSegmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.systemIndigo],
            for: .normal
        )
        self.viewSegmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.white],
            for: .selected
        )
        self.viewSegmentedControl.selectedSegmentTintColor = .systemIndigo
        self.viewSegmentedControl.backgroundColor = .white
        self.viewSegmentedControl.layer.borderColor = UIColor.systemIndigo.cgColor
        self.viewSegmentedControl.layer.borderWidth = 1
    }
    
}

