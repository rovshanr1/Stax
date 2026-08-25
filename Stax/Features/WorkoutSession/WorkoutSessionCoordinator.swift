//
//  WorkoutSessionCoordinator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 07.12.25.
//

import UIKit

enum WorkoutSessionEvent{
    case addExercise(onSelected: (ExerciseDomainModel) -> Void)
    case replaceExercise(WorkoutExerciseDomainModel, onSelected: (ExerciseDomainModel) -> Void)
    case finishWorkout(workoutID: String, stats: WorkoutStats)
    case cancelWorkout
}

final class WorkoutSessionCoordinator: Coordinator{
    //Standart Delegate
    weak var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    
    private let factory: WorkoutSessionCoordinatorFactory
    
    private let workoutId: String?
    
    init(_ navigationController: UINavigationController, factory: WorkoutSessionCoordinatorFactory, workoutId: String? = nil) {
        self.navigationController = navigationController
        self.workoutId = workoutId
        self.factory = factory
    }
    
    
    func start() {
        let sessionVC = factory.makeWorkoutSessionVC(workoutID: workoutId)
        
        sessionVC.didSendEventClosure = { [weak self] event in
            self?.handle(event)
        }
        
        
        navigationController.setViewControllers([sessionVC], animated: false)
    }
    
    func finish() {
        navigationController.dismiss(animated: true)
        
        childCoordinators.forEach { $0.finish() }
        childCoordinators.removeAll()
        
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
    
    private func handle(_ event: WorkoutSessionEvent) {
        switch event {
        case .addExercise(let onSelected):
            showExerciseList(onExerciseSelected: onSelected)
        case .replaceExercise(_, let onSelected):
            showExerciseList(onExerciseSelected: onSelected)
        case .cancelWorkout:
            finish()
        case .finishWorkout(let workoutID, let stats):
            showWorkoutSummary(workoutID: workoutID, stats: stats)
        }
    }
    
    
    private func showExerciseList(onExerciseSelected: @escaping (ExerciseDomainModel) -> Void) {
        let listNav = UINavigationController()
        listNav.modalPresentationStyle = .fullScreen
        
        let exerciseCoordinator = factory.makeExerciseListCoordinator(navigationController: listNav)
        exerciseCoordinator.finishDelegate = self
        
        exerciseCoordinator.didFinishWithSelection = { selectedExercise in
            onExerciseSelected(selectedExercise)
        }
        
        childCoordinators.append(exerciseCoordinator)
        exerciseCoordinator.start()
        
        navigationController.present(listNav, animated: true)
    }
    
    private func showWorkoutSummary(workoutID: String, stats: WorkoutStats) {
        let summaryCoordinator = factory.makeWorkoutSummaryCoordinator(
            navigationController: navigationController,
            workoutID: workoutID,
            stats: stats
        )
        summaryCoordinator.finishDelegate = self
        summaryCoordinator.onWorkoutSaved = { [weak self] in self?.finish() }
        summaryCoordinator.onWorkoutDiscarded = { [weak self] in self?.finish() }
        
        childCoordinators.append(summaryCoordinator)
        summaryCoordinator.start()
    }
}

extension WorkoutSessionCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== childCoordinator }
        
        if childCoordinator is ExerciseListCoordinator{
            navigationController.presentedViewController?.dismiss(animated: true)
        }
        
    }
}
