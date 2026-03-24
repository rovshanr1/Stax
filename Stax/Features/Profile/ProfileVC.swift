//
//  ProfileVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 28.11.25.
//

import UIKit

class ProfileVC: UIViewController {
    var didSendEventClosure: ((ProfileEvent) -> Void)?
        
    var contentView = ProfileUIView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Profile"
        
    }
    
    override func loadView() {
        self.view = contentView
    }
    
}
