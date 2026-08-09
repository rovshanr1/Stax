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
    
    
    //Injection
    var vm: WorkoutDetailVM?
    
    //Container
    private let factory: DefaultWorkoutDetailFactory
    
    //States
    private let workoutID: String
    
    init(navigationController: UINavigationController, factory: DefaultWorkoutDetailFactory, workoutID: String) {
        self.navigationController = navigationController
        self.factory = factory
        self.workoutID = workoutID
    }
    
    func start() {
        let viewController = factory.makeWorkoutDetailVC(workoutID: workoutID)
        
        viewController.hidesBottomBarWhenPushed = true
        
        viewController.didSendEventClosure = {[weak self] event in
            self?.handle(event)
        }
        
        navigationController.pushViewController(viewController, animated: true)
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
