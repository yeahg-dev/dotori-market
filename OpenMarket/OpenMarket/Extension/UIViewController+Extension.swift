//
//  UIViewController+Extension.swift
//  OpenMarket
//
//  Created by lily on 2022/01/24.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
