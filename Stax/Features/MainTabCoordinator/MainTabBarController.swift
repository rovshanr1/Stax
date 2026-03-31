//
//  MainTabBarController.swift
//  Stax
//
//  Created by Rovshan Rasulov on 02.03.26.
//

import UIKit
final class MainTabBarController: UITabBarController{
    override var childForStatusBarStyle: UIViewController? {
        if let navController = selectedViewController as? UINavigationController{
            return navController.visibleViewController
        }
        
        return selectedViewController
    }
    
    override var childForStatusBarHidden: UIViewController? {
        if let navController = selectedViewController as? UINavigationController{
            return navController.visibleViewController
        }
        return selectedViewController
    }
    
  
}

