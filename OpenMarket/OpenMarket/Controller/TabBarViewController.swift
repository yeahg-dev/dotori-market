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
        tabBar.isHidden = true
        configureViewSegmentedControl()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let productRegistrationViewController = segue.destination as? ProductRegistrationViewController {
            productRegistrationViewController.refreshDelegate = selectedViewController as? RefreshDelegate
        }
    }
    
    @IBAction private func switchViewController(_ sender: UISegmentedControl) {
        selectedIndex = sender.selectedSegmentIndex
    }
    
    private func configureViewSegmentedControl() {
        viewSegmentedControl.setTitle("LIST", forSegmentAt: 0)
        viewSegmentedControl.setTitle("GRID", forSegmentAt: 1)
        viewSegmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.systemIndigo],
            for: .normal
        )
        viewSegmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.white],
            for: .selected
        )
        viewSegmentedControl.selectedSegmentTintColor = .systemIndigo
        viewSegmentedControl.backgroundColor = .white
        viewSegmentedControl.layer.borderColor = UIColor.systemIndigo.cgColor
        viewSegmentedControl.layer.borderWidth = 1
    }
    
}

