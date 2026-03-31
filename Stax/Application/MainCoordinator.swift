//
//  MainCoordinator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 28.11.25.
//

import UIKit
import CoreData

//MARK: - MainCoordinator
protocol MainCoordinatorProtocol: Coordinator{
    func authFlow()
    func showMainFlow()
}


class MainCoordinator: MainCoordinatorProtocol{
    weak var finishDelegate: CoordinatorFinishDelegate? = nil
    
    var childCoordinators = [Coordinator]()
    
    var navigationController: UINavigationController
    
    var type: CoordinatorType { return .app }
    
    let context: NSManagedObjectContext
    
    init(_ navigationController: UINavigationController, context: NSManagedObjectContext) {
        self.navigationController = navigationController
        self.context = context
    }
    
    func start() {
        
        if let _ = KeychainHelper.shared.read(){
            showMainFlow()
        }else{
            authFlow()
        }
        
       showMainFlow()
    }
    
    func authFlow() {
        print("onboarding flow")
    }
    
    func showMainFlow() {
        let tabCoordinator = TabCoordinator(navigationController, context: context)
        tabCoordinator.finishDelegate = self
        navigationController.setNavigationBarHidden(true, animated: false)
        tabCoordinator.start()
        childCoordinators.append(tabCoordinator)
    }
}


//MARK: - CoordinatorFinishDelegate
extension MainCoordinator: CoordinatorFinishDelegate{
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter({ $0 !== childCoordinator})
        
        switch childCoordinator.type {
        case .tab:
            navigationController.viewControllers.removeAll()
            authFlow()
        case .auth:
            navigationController.viewControllers.removeAll()
            showMainFlow()
        default:
            break
        }
    }
}
