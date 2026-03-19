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
    case cancelWorkout
    case exerciseMenuButtonTapped(WorkoutExercise)
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
        
        //Ropsiotory Injection
        let workoutRepo = DataRepository<Workout>(context: context)
        let exerciseRepo = DataRepository<WorkoutExercise>(context: context)
        let exerciseSetsRepo = DataRepository<WorkoutSet>(context: context)
        
        //VM Injection
        self.vm = WorkoutSessionViewModel(workoutRepo: workoutRepo, exerciseRepo: exerciseRepo, workoutSets: exerciseSetsRepo)

        sessionVC.viewModel = self.vm
        
        navigationController.setViewControllers([sessionVC], animated: false)
    }
    
    func finish() {
        if navigationController.presentedViewController != nil{
            navigationController.dismiss(animated: true)
        }
        
        cancellables.removeAll()
        vm = nil
        
        childCoordinators.forEach { $0.finish() }
        childCoordinators.removeAll()
        
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
    
    private func handle (_ event: WorkoutSessionEvent){
        switch event {
        case .addExercise:
            self.showExerciseList()
        case .cancelWorkout:
            self.finish()
        case .finishWorkout:
            self.showWorkoutSummary()
        case .exerciseMenuButtonTapped(let exerciseToEdit):
            self.showExerciseMenu(for: exerciseToEdit)
        }
    }
    
    
    private func showExerciseList(onExerciseSelected: ((Exercise) -> Void)? = nil) {
        let listNav = UINavigationController()
        listNav.modalPresentationStyle = .fullScreen
        
        let exerciseCoordinator = ExerciseListCoordinator(listNav, context: context)
        exerciseCoordinator.finishDelegate = self
        
        exerciseCoordinator.didFinishWithSelection = {[weak self] selectedExercise in
            guard let self else {return}
            
            if let customAction = onExerciseSelected {
                customAction(selectedExercise)
            }else{
                self.vm?.input.addExercise.send(selectedExercise)
            }
            
            
        }
        
        childCoordinators.append(exerciseCoordinator)
        exerciseCoordinator.start()
        
        navigationController.present(listNav, animated: true)
    }
    
    private func showWorkoutSummary(){
        
        guard let currentWorkout = vm?.currentWorkout,
              let stats = vm?.currentStats,
              let duration = vm?.timerService.seconsElapsed
        else {return}
        
        let summaryStats = WorkoutStats(
            duration: TimeInterval(duration),
            volume: stats.volume,
            totalSets: stats.sets
        )
        
        let summaryCoordinator = WorkoutSummaryCoordinator(navigationController: navigationController, context: context, workout: currentWorkout, stats: summaryStats)
        summaryCoordinator.finishDelegate = self
        
        summaryCoordinator.onWorkoutSaved = {[weak self] in
            self?.finish()
        }
        
        summaryCoordinator.onWorkoutDiscarded = {[weak self] in
            self?.finish()
        }
        
        childCoordinators.append(summaryCoordinator)
        summaryCoordinator.start()
    }
    
    private func showExerciseMenu(for exercise: WorkoutExercise){
        let sheetNav = ExerciseMenuSheet()
        sheetNav.modalPresentationStyle = .pageSheet
        
        if let sheet = sheetNav.sheetPresentationController {
            sheet.detents = [
                .custom(identifier: .init("small")) { context in
                    return 120
                }
            ]
            sheet.prefersGrabberVisible = true
        }
        
        sheetNav.onActionSelected = { [weak self] action in
            self?.handleExerciseMenuAction(action, for: exercise)
        }
        
        navigationController.present(sheetNav, animated: true)
    }
    
    
    private func handleExerciseMenuAction(_ action: ExerciseMenuSheet.Action, for exercise: WorkoutExercise){
        
        navigationController.dismiss(animated: true) { [weak self]  in
            guard let self else { return }
         
            switch action{
            case .replaceExercise:
                self.showExerciseList {[weak self] newExerciseDef in
                    self?.vm?.input.replaceExercise.send((exercise, newExerciseDef))
                }
                
            case .deleteExercise:
                self.vm?.input.deleteExercise.send(exercise)
            }
        }
       
    }
}

extension WorkoutSessionCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== childCoordinator }
        
        switch childCoordinator.type {
        case .exerciseList:
            navigationController.presentedViewController?.dismiss(animated: true)
        default:
            break
        }
    }
}
