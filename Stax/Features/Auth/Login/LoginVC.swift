//
//  LoginVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 01.04.26.
//

import UIKit

class LoginVC: UIViewController {
    //Closures
    var tappedSignUp: (() -> Void)?

    //ViewModel
    var vm: LoginVM
    
    //ContentView
    private let contentView = LoginView()
    
    init(vm: LoginVM) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        
        bindActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        self.view = contentView
    }

    private func bindActions() {
        contentView.onTapSignUp = { [weak self] in
            self?.tappedSignUp?()
        }
    }
}
