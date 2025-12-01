//
//  ExerciseCoordinator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 01.12.25.
//

import UIKit

enum ExerciseEvent{
    
}


final class ExerciseCoordinator: Coordinator{
    var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    var type: CoordinatorType {.page}
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let exerciseVC = ExerciseVC()
        
        //TODO: - event handling is here
//        exerciseVC.didSendEventClosure = {[weak self] event in
//            
//        }
        
        navigationController.pushViewController(exerciseVC, animated: true)
    }
    
    
    private func handle(_ event: ExerciseEvent){
        
    }
}
