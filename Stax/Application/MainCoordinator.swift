//
//  MainCoordinator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 28.11.25.
//

import UIKit
import Combine
import FirebaseAuth

//MARK: - MainCoordinator
protocol MainCoordinatorProtocol: Coordinator{
    func authFlow()
    func showMainFlow()
    func showSplashView()
}


class MainCoordinator: MainCoordinatorProtocol{
    weak var finishDelegate: CoordinatorFinishDelegate? = nil
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
   
    //Container
    var appDIContainer: AppDIContainer
   
    var cancellables: Set<AnyCancellable> = []
    
    init(_ navigationController: UINavigationController, appDIContainer: AppDIContainer) {
        self.navigationController = navigationController
        self.appDIContainer = appDIContainer
    }
    
    func start() {
        
        handleIsFirstLaunchCompleted()
        
        if Auth.auth().currentUser != nil{
            showSplashView()
        }else{
            authFlow()
        }
    }
    
    func showSplashView(){
        let (splashVC, splashVM) = SplashModuleBuilder.build(container: appDIContainer)
    
        
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.setViewControllers([splashVC], animated: false)
        
        splashVM.output.syncCompleted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else { return }
                self.showMainFlow()
            }
            .store(in: &cancellables)
    }
    
    func authFlow() {
        let authCoordinator = AuthCoordinator(navigationController)
        authCoordinator.finishDelegate = self
        authCoordinator.start()
        navigationController.setNavigationBarHidden(true, animated: false)
        childCoordinators.append(authCoordinator)
    }
    
    func showMainFlow() {
        let tabCoordinator = TabCoordinator(navigationController, appDIContainer: appDIContainer)
        tabCoordinator.finishDelegate = self
        navigationController.setNavigationBarHidden(true, animated: false)
        tabCoordinator.start()
        childCoordinators.append(tabCoordinator)
    }
    
    func handleIsFirstLaunchCompleted() {
        let defaults = UserDefaults.standard
        
        if defaults.bool(forKey: UserDefaultsKeys.isFirstLaunchCompleted) == false{
            
            try? Auth.auth().signOut()
            
            defaults.set(true, forKey: UserDefaultsKeys.isFirstLaunchCompleted)
        }
    }
}


//MARK: - CoordinatorFinishDelegate
extension MainCoordinator: CoordinatorFinishDelegate{
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter({ $0 !== childCoordinator})
        
        
        if childCoordinator is TabCoordinator{
            animatedAndResetAppFlow()
        }else if childCoordinator is AuthCoordinator{
            navigationController.viewControllers.removeAll()
            showSplashView()
        }
    }
    
    
    private func animatedAndResetAppFlow(){
     
        guard let window = navigationController.view.window,
              let snapshot = window.snapshotView(afterScreenUpdates: false) else {
            
            performDataResetAndGoToAuth()
            return
        }
        
        window.addSubview(snapshot)
        
        performDataResetAndGoToAuth()
        
        UIView.animate(withDuration: 0.4, delay:0, options: .curveEaseInOut ,animations: {
            snapshot.alpha = 0.0
            snapshot.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }) { _ in
            snapshot.removeFromSuperview()
        }
    }
    
    
    private func performDataResetAndGoToAuth() {
        navigationController.viewControllers.removeAll()
        
        try? appDIContainer.persistenceController.resetStack()
        
        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.isSeededFromFirebase)
        
        let newUserManager = UserManager()
        let newPersistenceController = PersistenceController()
        
        let newDIContainer = AppDIContainer(userManager: newUserManager, persistenceController: newPersistenceController)
        
        self.appDIContainer = newDIContainer
        
        authFlow()
    }
}
