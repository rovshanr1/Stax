//
//  ProfileCoordinator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 01.12.25.
//

import UIKit


enum ProfileEvent{
    case showProfilePhoto
}

final class ProfileCoordinator: Coordinator{
    var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    var type: CoordinatorType { .page }
    
    
    var workoutRepo: WorkoutRepositoryProtocol
    
    
    init(_ navigationController: UINavigationController, workoutRepo: WorkoutRepositoryProtocol) {
        self.navigationController = navigationController
        self.workoutRepo = workoutRepo
    }
    
    func start() {
        
        let vm = ProfileVM(workoutRepo: workoutRepo)
        
        let profileVC = ProfileVC(viewModel: vm)
        
        
        profileVC.didSendEventClosure = { [weak self] event in
            self?.handle(event)
        }
        
        profileVC.navigationItem.largeTitleDisplayMode = .always
        navigationController.setViewControllers([profileVC], animated: false)
    }
    
    private func handle(_ event: ProfileEvent) {
        switch event {
        case .showProfilePhoto:
            print("")
        }
    }
    
    
  
}

