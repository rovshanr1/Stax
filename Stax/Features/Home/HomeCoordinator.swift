//
//  HomeCoordinator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 01.12.25.
//

import UIKit

enum HomeEvent{
    case buttonTapped
}


final class HomeCoordinator: Coordinator{
    var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    var type: CoordinatorType { .page }
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let homeVC = HomeVC()
        
        //TODO: - handle event closure
//        homeVC.didSendEventClosure = { [weak self] event in
//
//        }
        homeVC.navigationItem.largeTitleDisplayMode = .always
        
        navigationController.setViewControllers([homeVC], animated: false)
        
    }
    
    private func handle(_ event: HomeEvent){
        
    }
}
