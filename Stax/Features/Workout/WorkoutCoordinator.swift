//
//  WorkoutCoordinator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 01.12.25.
//

import UIKit

enum ExerciseEvent{
    case startEmptyWorkout
    
}


final class WorkoutCoordinator: Coordinator{
    var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    var type: CoordinatorType {.page}
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    
    func start() {
        let exerciseVC = WorkoutVC()
        
        exerciseVC.didSendEventClosure = {[weak self] event in
            guard let self else { return }
            
            switch event{
            case .startEmptyWorkout:
                self.showActiveWorkout()
            }
        }
        
        navigationController.pushViewController(exerciseVC, animated: true)
    }
    
    
    private func handle(_ event: ExerciseEvent){
        
    }
    
    private func showActiveWorkout(){
        let activeSessionVC = WorkoutSessionVC()
        let nav = UINavigationController(rootViewController: activeSessionVC)
        
        nav.modalPresentationStyle = .fullScreen
        navigationController.present(nav, animated: true)
    }
}
