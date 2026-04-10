//
//  SignUpVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 01.04.26.
//

import UIKit
import Combine

class SignUpVC: UIViewController {
    
    private let contentView = SignUpView()
    
    var didSentEventClosure: ((AuthEvent) -> Void)?
    
    private var vm: SignUpVM
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(vm: SignUpVM) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        bindAction()
      
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)    }
    
    override func loadView() {
        self.view = contentView
    }
  
    
    deinit{
        print("SignUpVC deinited")
    }
    
    private func bindAction(){
        contentView.updateName = { [weak self] text in
            self?.vm.input.updateName.send(text)
        }
      
        contentView.updateEmail = {[weak self] text in
            self?.vm.input.updateEmail.send(text)
        }
        
        contentView.updatePassword = {[weak self] text in
            self?.vm.input.updatePassword.send(text)
        }
        
        contentView.signInTapped = { [weak self] in
            self?.didSentEventClosure?(.dismissSignUpScreen)
        }
        
        contentView.signUpTapped = { [weak self] in
            self?.vm.input.didTapSignUp.send(())
        }
        
    }
    
    private func bindViewModel(){
        vm.output.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.contentView.configurationContentView(isLoading: isLoading)
            }
            .store(in: &cancellables)
        
        vm.output.buttonIsEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.contentView.configureButtonSignUp(isEnabled)
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
                guard let self else { return }
                guard success else { return }
                
                self.didSentEventClosure?(.authSuccess)
            }
            .store(in: &cancellables)
        
    }
}
