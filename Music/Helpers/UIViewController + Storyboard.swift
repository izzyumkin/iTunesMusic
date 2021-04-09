//
//  UIViewController + Storyboard.swift
//  Music
//
//  Created by Иван Изюмкин on 10.03.2021.
//

import UIKit

extension UIViewController {
    
    class func loadFromStoryboard<T: UIViewController>() -> T {
        
        let name = String(describing: T.self)
        let storyboard = UIStoryboard(name: name, bundle: nil)
        
        if let viewController = storyboard.instantiateInitialViewController() as? T {
            return viewController
        } else {
            fatalError("Error: \(name) not found in storyboard :(")
        }
        
    }
    
}
