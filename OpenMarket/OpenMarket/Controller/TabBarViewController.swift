//
//  OpenMarket - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

class TabBarViewController: UITabBarController {
    
    @IBOutlet private weak var viewSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewSegmentedControl()
    }

    private func configureViewSegmentedControl() {
        viewSegmentedControl.setTitle("LIST", forSegmentAt: 0)
        viewSegmentedControl.setTitle("GRID", forSegmentAt: 1)
        viewSegmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.systemBlue],
            for: .normal
        )
        viewSegmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.white],
            for: .selected
        )
        viewSegmentedControl.selectedSegmentTintColor = .systemBlue
        viewSegmentedControl.backgroundColor = .white
        viewSegmentedControl.layer.borderColor = UIColor.systemBlue.cgColor
        viewSegmentedControl.layer.borderWidth = 1
    }
    
}

