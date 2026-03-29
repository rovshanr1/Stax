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
    let context: NSManagedObjectContext
    
    //Injection
    var vm: WorkoutDetailVM?
    
    //States
    let workoutID: String
    
    
    init(navigationController: UINavigationController, context: NSManagedObjectContext, workoutID: String) {
        self.navigationController = navigationController
        self.context = context
        self.workoutID = workoutID
    }
    
    func start() {
        let workoutDetailVC = WorkoutDetailVC()
        
        //Repo injection
        let genericRepo = DataRepository<Workout>(context: context)
        let workoutRepo = WorkoutRepository(genericRoository: genericRepo)
        
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
