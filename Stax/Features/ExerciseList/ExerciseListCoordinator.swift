//
//  ExerciseListCoordinator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 10.12.25.
//

import UIKit
import CoreData

enum ExerciseListEvent{
    case cancel
    case exerciseSelected(Exercise)
}

final class ExerciseListCoordinator: Coordinator {
    var didFinishWithSelection: ((Exercise) -> Void)?
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    var type: CoordinatorType { .exerciseList }
    
    let context: NSManagedObjectContext
    
    init(_ navigationController: UINavigationController, context: NSManagedObjectContext){
        self.navigationController = navigationController
        self.context = context
    }
    
    func start() {
        let exerciseListVC = ExerciseListVC()
        
        exerciseListVC.didSendEventClosure = { [weak self] event in
            self?.handle(event)
        }
        
        //TODO: - DI ViewModel
        let dataRepo = DataRepository<Exercise>(context: context)
        let viewModel = ExerciseListVM(dataRepo: dataRepo)
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
