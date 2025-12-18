//
//  WorkoutSessionCoordinator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 07.12.25.
//

import UIKit
import Combine
import CoreData

enum WorkoutSessionEvent{
    case addExercise
    case finishWorkout
}

final class WorkoutSessionCoordinator: Coordinator{
    //StandartDelegate
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var vm: WorkoutSessionViewModel?
    
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    var type: CoordinatorType { .workoutSession}
    
    let context: NSManagedObjectContext
    
    var cancellables: Set<AnyCancellable> = []
    
    init(_ navigationController: UINavigationController, context: NSManagedObjectContext) {
        self.navigationController = navigationController
        self.context = context
    }
    
    
    func start() {
        let sessionVC = WorkoutSessionVC()
        
        sessionVC.didSendEventClosure = { [weak self] event in
            self?.handle(event)
        }
        
        //VM Injection
        let workoutRepo = DataRepository<Workout>(context: context)
        let exerciseRepo = DataRepository<WorkoutExercise>(context: context)
        self.vm = WorkoutSessionViewModel(workoutRepo: workoutRepo, exerciseRepo: exerciseRepo)

        sessionVC.viewModel = self.vm
        
        navigationController.viewControllers = [sessionVC]
    }
    
    private func handle (_ event: WorkoutSessionEvent){
        switch event {
        case .addExercise:
            self.showExerciseList()
        case .finishWorkout:
            self.finish()
        }
    }
    
    private func showExerciseList(){
        let listNav = UINavigationController()
        listNav.modalPresentationStyle = .fullScreen
        
        let exerciseCoordinator = ExerciseListCoordinator(listNav, context: context)
        exerciseCoordinator.finishDelegate = self
        
        exerciseCoordinator.didFinishWithSelection = {[weak self] selectedExercise in
            guard let self else {return}
         
            
            self.vm?.input.addExercise.send(selectedExercise)
        }
        
        childCoordinators.append(exerciseCoordinator)
        exerciseCoordinator.start()
        
        navigationController.present(listNav, animated: true)
    }
}

extension WorkoutSessionCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== childCoordinator }
        
        switch childCoordinator.type {
        case .exerciseList:
            navigationController.dismiss(animated: true)
        default:
            break
        }
    }
}
