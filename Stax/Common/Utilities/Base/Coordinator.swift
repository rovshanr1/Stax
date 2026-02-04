//
//  Coordinator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 28.11.25.
//

import UIKit
//MARK: - CoordinatorType
enum CoordinatorType{
    case app, login, tab, page, workoutSession, exerciseList, workoutSummary
}

//MARK: - Coordinator
protocol Coordinator: AnyObject{
    var finishDelegate: CoordinatorFinishDelegate? { get set}
    
    //array to keep tracking of all child coordinators
    var childCoordinators: [Coordinator] { get set }
    
    //Each coordinator has one navigation controller assigned to it
    var navigationController: UINavigationController { get set }
    
    //Defined flow type
    var type: CoordinatorType { get }

    //A place to put logic to start the flow
    func start()
    
    /// A place to put logic to finish the flow, to clean all children coordinators, and to notify the parent that this coordinator is ready to be deallocated
    func finish()
}

//MARK: - CoordinatorExtension
extension Coordinator{
    func finish() {
        childCoordinators.removeAll()
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}


//MARK: - CoordinatorOutput
protocol CoordinatorFinishDelegate: AnyObject{
    func coordinatorDidFinish(childCoordinator: Coordinator)
}
