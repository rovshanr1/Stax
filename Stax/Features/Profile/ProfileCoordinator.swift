//
//  ProfileCoordinator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 01.12.25.
//

import UIKit

enum ProfileEvent{
    
}

final class ProfileCoordinator: Coordinator{
    var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    var type: CoordinatorType { .page }
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let profileVC = ProfileVC()
        
        //TODO: - event handling is here
//        profileVC.didSendEventClosure = { [weak self] event in
//            
//        }
        
        navigationController.pushViewController(profileVC, animated: true)
    }
    
    private func handle(_ event: ProfileEvent) {
        
    }
}
