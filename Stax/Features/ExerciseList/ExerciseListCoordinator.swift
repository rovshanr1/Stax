//
//  ExerciseListCoordinator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 10.12.25.
//

import UIKit


enum ExerciseListEvent{
    case cancel
    case exerciseSelected(ExerciseDomainModel)
}

final class ExerciseListCoordinator: Coordinator {
    var didFinishWithSelection: ((ExerciseDomainModel) -> Void)?
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    let factory: ExerciseListCoordinatorFactory
    
    init(_ navigationController: UINavigationController, factory: ExerciseListCoordinatorFactory){
        self.navigationController = navigationController
        self.factory = factory
    }
    
    func start() {

        let exerciseListVC = factory.makeExerciseList()
        
        exerciseListVC.didSendEventClosure = { [weak self] event in
            self?.handle(event)
        }
        
        navigationController.pushViewController(exerciseListVC, animated: true)
    }
    
    
    private func handle (_ event: ExerciseListEvent){
        switch event{
        case .cancel:
            self.finish()
        case .exerciseSelected(let exercise):
            didFinishWithSelection?(exercise)
            self.finish()
        }
    }
    
}
