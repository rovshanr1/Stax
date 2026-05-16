//
//  WorkoutDetailCoordinator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 23.03.26.
//

import UIKit
import CoreData
import Combine

enum WorkoutDetailEvent{
    case dismiss
}

final class WorkoutDetailCoordinator: Coordinator{
    
    //Coordinator
    var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var type: CoordinatorType { .workoutDetail }
    
    //Injection
    var vm: WorkoutDetailVM?
    
    //States
    private let workoutID: String
    
    //Container
    private let appDIContainer: AppDIContainer
    
    
    init(navigationController: UINavigationController, appDIContainer: AppDIContainer, workoutID: String) {
        self.navigationController = navigationController
        self.appDIContainer = appDIContainer
        self.workoutID = workoutID
    }
    
    func start() {
        let workoutDetailVC = WorkoutDetailVC()
        
        //VM injection
        self.vm = WorkoutDetailVM(workoutID: workoutID, workoutRepo: appDIContainer.sharedWorkoutRepo)
        workoutDetailVC.vm = self.vm
        
        workoutDetailVC.hidesBottomBarWhenPushed = true
        
        workoutDetailVC.didSendEventClosure = {[weak self] event in
            self?.handle(event)
        }
        
        navigationController.pushViewController(workoutDetailVC, animated: true)
    }
    
    
    private func handle(_ event: WorkoutDetailEvent) {
        switch event {
        case .dismiss:
            finishDelegate?.coordinatorDidFinish(childCoordinator: self)
        }
    }
    
}

extension WorkoutDetailCoordinator: CoordinatorFinishDelegate{
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter({$0 !== childCoordinator })
    }
}
