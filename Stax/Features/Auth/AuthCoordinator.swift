//
//  AuthCoordinator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 31.03.26.
//

import UIKit
import CoreData

enum AuthRoute{
    case welcome
    case login
    case signUp
}

protocol AuthCoordinatorProtocol: Coordinator{
    func navigate(to route: AuthRoute)
    func didFinishAuth()
}


final class AuthCoordinator: AuthCoordinatorProtocol {
    weak var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    var type: CoordinatorType { .auth }
    
    let context: NSManagedObjectContext
    
    private lazy var authService: AuthServiceProtocol = {
            return AuthService(context: self.context)
    }()
    
    init(_ navigationController: UINavigationController, context: NSManagedObjectContext) {
        self.navigationController = navigationController
        self.context = context
    }
    
    

    
    func start() {
        navigate(to: .welcome)
    }
    
    func navigate(to route: AuthRoute) {
        switch route{
            
        case .welcome:
            self.showWelcomeScreen()
        case .login:
            self.showLoginScreen()
        case .signUp:
            self.showSignUpScreen()
        }
    }
    
    func showWelcomeScreen() {
        let vm = WelcomeVM()
        let welcomeVC = WelcomeVC()
        welcomeVC.vm = vm
        
        welcomeVC.onToLogin = { [weak self] in
            self?.navigate(to: .login)
        }
        
        navigationController.setViewControllers([welcomeVC], animated: false)
    }
    
    func showLoginScreen() {
        
        let vm = LoginVM(authService: authService)
        
        let loginVC = LoginVC(vm: vm)
        
        loginVC.tappedSignUp = { [weak self] in
            self?.showSignUpScreen( )
        }
        
        navigationController.pushViewController(loginVC, animated: true)
    }
    
    func showSignUpScreen() {
        let signUpVM = SignUpVM(authService: authService)
        
        let signUpVC = SignUpVC()
        signUpVC.vm = signUpVM
        
        signUpVC.coordinator = self
        
        navigationController.pushViewController(signUpVC, animated: true)
    }
    
    func didFinishAuth() {
        finish()
    }
    
}

extension AuthCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: any Coordinator) {
        childCoordinators = childCoordinators.filter({$0 !== childCoordinator})
    }
}

