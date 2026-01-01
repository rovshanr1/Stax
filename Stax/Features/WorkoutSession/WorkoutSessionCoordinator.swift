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
    case exerciseMenuButtonTapped
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
        let exerciseSetsRepo = DataRepository<WorkoutSet>(context: context)
        
        self.vm = WorkoutSessionViewModel(workoutRepo: workoutRepo, exerciseRepo: exerciseRepo, workoutSets: exerciseSetsRepo)

        sessionVC.viewModel = self.vm
        
        navigationController.viewControllers = [sessionVC]
    }
    
    private func handle (_ event: WorkoutSessionEvent){
        switch event {
        case .addExercise:
            self.showExerciseList()
        case .finishWorkout:
            self.finish()
        case .exerciseMenuButtonTapped:
            print("Button Tapped")
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
    
    private func showExerciseMenu(){
        let listNav = UINavigationController()
        listNav.modalPresentationStyle = .pageSheet
        
        
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
