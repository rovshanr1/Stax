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

enum AuthEvent{
    case dismissSignUpScreen
    case authSuccess
    case showSignUp
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
    
    
    private lazy var authService: AuthServiceProtocol = {
        return AuthService()
    }()
    
    private lazy var userService: UserServiceProtocol = {
        return UserService()
    }()
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
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
    
    func handle(_ event: AuthEvent){
        switch event{
        case .dismissSignUpScreen:
            self.navigationController.popViewController(animated: true)
        case .authSuccess:
            didFinishAuth()
        case .showSignUp:
            self.showSignUpScreen()
        }
    }
    
    func showWelcomeScreen() {
        let welcomeVC = WelcomeVC()
        
        welcomeVC.onToLogin = { [weak self] in
            self?.navigate(to: .login)
        }
        
        navigationController.setViewControllers([welcomeVC], animated: false)
    }
    
    func showLoginScreen() {
        let loginVM = LoginVM(authService: authService)
        let loginVC = LoginVC(vm: loginVM)
        
        loginVC.didSentEventClosure = { [weak self] event in
            self?.handle(event)
        }
        
        loginVC.tappedSignUp = { [weak self] in
            self?.handle(.showSignUp)
        }
        
        
        navigationController.pushViewController(loginVC, animated: true)
    }
    
    func showSignUpScreen() {
        let signUpVM = SignUpVM(authService: authService, userService: userService)
        let signUpVC = SignUpVC(vm: signUpVM)
        
        signUpVC.didSentEventClosure = {[weak self] event in
            self?.handle(event)
        }
        
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

