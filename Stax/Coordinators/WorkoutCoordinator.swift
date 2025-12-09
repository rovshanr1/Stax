//
//  WorkoutCoordinator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 01.12.25.
//

import UIKit
import CoreData

enum WorkoutEvent{
    case startEmptyWorkout
}


final class WorkoutCoordinator: Coordinator{
    var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    var type: CoordinatorType {.page}
    
    let context: NSManagedObjectContext
    
    init(_ navigationController: UINavigationController, context: NSManagedObjectContext) {
        self.navigationController = navigationController
        self.context = context
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
    
    
    private func handle(_ event: WorkoutEvent){
        
    }
    
    private func showActiveWorkout(){
        let modalNav = UINavigationController()
        modalNav.modalPresentationStyle = .fullScreen
        
        let sessionCoordionator = WorkoutSessionCoordinator(modalNav, context: context)
        sessionCoordionator.finishDelegate = self
        
        childCoordinators.append(sessionCoordionator)
        sessionCoordionator.start()
        
        navigationController.present(modalNav, animated: true)
    }
}

extension WorkoutCoordinator: CoordinatorFinishDelegate{
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== childCoordinator }
        
        switch childCoordinator.type {
        case .pageSheet:
            navigationController.dismiss(animated: true)
        default:
            break
        }
    }
    
    
}
