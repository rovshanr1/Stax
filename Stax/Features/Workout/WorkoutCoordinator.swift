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
    
    
    
    //Container
    let appDIContainer: AppDIContainer
    
    init(_ navigationController: UINavigationController, appDIContainer: AppDIContainer) {
        self.navigationController = navigationController
        self.appDIContainer = appDIContainer
    }
    
    
    func start() {
        let workoutVC = WorkoutVC()
        
        workoutVC.didSendEventClosure = {[weak self] event in
            self?.handle(event)
        }
        workoutVC.navigationItem.largeTitleDisplayMode = .always
        
        navigationController.setViewControllers([workoutVC], animated: false)
    }
    
    
    private func handle(_ event: WorkoutEvent){
        switch event{
        case .startEmptyWorkout:
            self.showActiveWorkout()
        }
    }
    
    private func showActiveWorkout(){
        let modalNav = UINavigationController()
        modalNav.modalPresentationStyle = .fullScreen
        
        let sessionCoordionator = WorkoutSessionCoordinator(modalNav, appDIContainer: appDIContainer)
        sessionCoordionator.finishDelegate = self
        
        childCoordinators.append(sessionCoordionator)
        sessionCoordionator.start()
        
        navigationController.present(modalNav, animated: true)
    }
}

extension WorkoutCoordinator: CoordinatorFinishDelegate{
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== childCoordinator }
       
    }
    
    
}
