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
    
    
    
    let appDIContainer: AppDIContainer
    
    init(_ navigationController: UINavigationController, appDIContainer: AppDIContainer){
        self.navigationController = navigationController
        self.appDIContainer = appDIContainer
    }
    
    func start() {
        let exerciseListVC = ExerciseListVC()
        
        exerciseListVC.didSendEventClosure = { [weak self] event in
            self?.handle(event)
        }
        

        let viewModel = ExerciseListVM(repository: appDIContainer.sharedExerciseDefRepo)
        exerciseListVC.viewModel = viewModel
        
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
