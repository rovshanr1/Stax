//
//  MainCoordinator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 28.11.25.
//

import UIKit

//MARK: - MainCoordinator
protocol MainCoordinatorProtocol: Coordinator{
    func onboardingFLow()
    func showMainFlow()
}


class MainCoordinator: MainCoordinatorProtocol{
    weak var finishDelegate: CoordinatorFinishDelegate? = nil
    
    var childCoordinators = [Coordinator]()
    
    var navigationController: UINavigationController
    
    var type: CoordinatorType { return .tab }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    func start() {
       showMainFlow()
    }
    
    func onboardingFLow() {
        print("onboarding flow")
    }
    
    func showMainFlow() {
        let tabCoordinator = TabCoordinator(navigationController)
        tabCoordinator.finishDelegate = self
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
            showMainFlow()
            
        default:
            break
        }
    }
}
