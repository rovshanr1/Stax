//
//  WorkoutSessionCoordinator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 07.12.25.
//

import UIKit
import CoreData

enum WorkoutSessionEvent{
    case addExercise
    case finishWorkout
}

final class WorkoutSessionCoordinator: Coordinator{
    //StandartDelegate
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    var type: CoordinatorType { .pageSheet}
    
    let context: NSManagedObjectContext
    
    init(_ navigationController: UINavigationController, context: NSManagedObjectContext) {
        self.navigationController = navigationController
        self.context = context
    }
    
    
    func start() {
        let sessionVC = WorkoutSessionVC()
        
        sessionVC.didSendEventClosure = { [weak self] event in
            guard let self else { return }
            
            switch event {
            case .addExercise:
                self.showExerciseList()
            case .finishWorkout:
                self.finishSession()
            }
        }
        
        //TODO: - VM Injection
        
        navigationController.viewControllers = [sessionVC]
    }
    
    
    private func showExerciseList(){
        let listNav = UINavigationController()
        listNav.modalPresentationStyle = .pageSheet
        
        let exerciseListVC = UIViewController()
        exerciseListVC.view.backgroundColor = .red
        exerciseListVC.title = "Exercise List"
        
        navigationController.present(listNav, animated: true)
        
    }
    
    
    private func finishSession() {
        self.finish()
    }
    
}
