//
//  TabBarPage.swift
//  Stax
//
//  Created by Rovshan Rasulov on 28.11.25.
//

import UIKit

enum TabBarPage: Int, CaseIterable{
    case home, exercise, profile
    
    var title: String{
        switch self{
        case .home:
            return "Home"
        case .exercise:
            return "Exercise"
        case .profile:
            return "Profile"
        }
    }
    
    var icon: UIImage? {
        switch self{
        case .home:
            return UIImage(systemName: "house")
        case .exercise:
            return  UIImage(systemName: "dumbbell")
        case .profile:
            return UIImage(systemName: "person")
        }
    }
    
    var selectedIcon: UIImage? {
        switch self{
        case .home:
            return UIImage(systemName: "house.fill")
        case .exercise:
            return  UIImage(systemName: "dumbbell.fill")
        case .profile:
            return UIImage(systemName: "person.fill")
        }
    }
    var deselectedIcon: UIImage? {
      return icon
    }
}
