//
//  WelcomeVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 31.03.26.
//

import UIKit

enum WelcomeEventsFlow{
    case getStarted
}


class WelcomeVC: UIViewController {
    
    //Closures
    var onToLogin: (() -> Void)?
    
    //ViewModel
    var vm: WelcomeVM!
    
    private let welcomeView = WelcomeView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBind()
    }
    
    override func loadView() {
        self.view = welcomeView
    }
    
    private func setupBind(){
        welcomeView.onGetStartedTapped = { [weak self] in
            self?.onToLogin?()
        }
    }
}
