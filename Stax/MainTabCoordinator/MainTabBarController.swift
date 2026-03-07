//
//  MainTabBarController.swift
//  Stax
//
//  Created by Rovshan Rasulov on 02.03.26.
//

import UIKit
final class MainTabBarController: UITabBarController{
    override var childForStatusBarStyle: UIViewController? {
        selectedViewController
    }
    
    override var childForStatusBarHidden: UIViewController? {
        selectedViewController
    }
}
