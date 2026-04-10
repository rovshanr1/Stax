//
//  LoginVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 01.04.26.
//

import UIKit
import Combine

class LoginVC: UIViewController {
    //Closures
    var tappedSignUp: (() -> Void)?

    //ViewModel
   private var vm: LoginVM
    
    //ContentView
    private let contentView = LoginView()
    
    var didSentEventClosure: ((AuthEvent) -> Void)?
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(vm: LoginVM) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindActions()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func loadView() {
        self.view = contentView
    }
    
    deinit{
        print("LoginVC Deinited")
    }
    
    
    private func bindActions() {
        contentView.onTapSignUp = { [weak self] in
            self?.tappedSignUp?()
        }
        
        contentView.onTapLogin = { [weak self] in
            self?.vm.input.didTapLogin.send()
        }
        
        contentView.didChangeEmail = { [weak self] email in
            self?.vm.input.updateEmail.send(email)
        }
        
        contentView.didChangePassword = { [weak self] password in
            self?.vm.input.updatePassword.send(password)
        }
    }
    
    private func bindViewModel() {
        vm.output.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.contentView.configurationLoginView(isLoading: isLoading)
            }
            .store(in: &cancellables)
        
        vm.output.buttonIsEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.contentView.configureLoginButton(isEnabled: isEnabled)
            }
            .store(in: &cancellables)
        
        vm.output.errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                guard let self else { return }
                AlertManager.showErrorAlert(on: self, message: errorMessage)
            }
            .store(in: &cancellables)
        
        vm.output.success
            .receive(on: DispatchQueue.main)
            .sink { [weak self] success in
                guard success else { return }
                
                self?.didSentEventClosure?(.authSuccess)
            }
            .store(in: &cancellables)
    }
}
