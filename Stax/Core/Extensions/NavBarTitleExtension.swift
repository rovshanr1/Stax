//
//  NavBarTitleExtension.swift
//  Stax
//
//  Created by Rovshan Rasulov on 19.04.26.
//

import UIKit
import SnapKit

extension UIViewController {
    
    /// Adds a large and fixed title to the left side of the navigation bar.
    /// Disables the default iOS large title collapsing/scrolling behavior.
    func setupLeftAlignedNavigationTitle(with text: String) {
        self.title = ""
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        let leftTitleLabel = UILabel()
        leftTitleLabel.text = text
        leftTitleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        leftTitleLabel.textColor = .label
        
        
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftTitleLabel)
        
        if #available(iOS 26.0, *) {
            navigationItem.leftBarButtonItem?.hidesSharedBackground = true
        }
    }
}
