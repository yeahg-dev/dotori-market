//
//  Storyboard+Extension.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/19.
//

import UIKit

enum StoryboardType {

    case main

    var name: String {
        switch self {
        case .main:
            return "Main"
        }
    }

}

extension UIStoryboard {
    
    static let main = UIStoryboard(name: StoryboardType.main.name, bundle: nil)

    class func initiateViewController<T: UIViewController>(_ type: T.Type, storyboardType: StoryboardType = .main) -> T {
        let storyboard = UIStoryboard(name: storyboardType.name, bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: type.className) as? T else {
            assertionFailure("UIStoryboard Instantiate ViewController Failed")
            return T.init()
        }
        return vc
    }

}
