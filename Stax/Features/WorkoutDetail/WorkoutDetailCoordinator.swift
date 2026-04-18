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
    private let workoutRepo: WorkoutRepositoryProtocol
    
    
    init(navigationController: UINavigationController, workoutID: String, workoutRepo: WorkoutRepositoryProtocol) {
        self.navigationController = navigationController
        self.workoutID = workoutID
        self.workoutRepo = workoutRepo
    }
    
    func start() {
        let workoutDetailVC = WorkoutDetailVC()
        
        //VM injection
        self.vm = WorkoutDetailVM(workoutID: workoutID, workoutRepo: workoutRepo)
        workoutDetailVC.vm = self.vm
        
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
