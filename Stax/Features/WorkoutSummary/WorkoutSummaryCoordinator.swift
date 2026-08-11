//
//  WorkoutSummaryCoordinator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 31.01.26.
//

import UIKit
import Combine


enum WorkoutSummaryEvent{
    case workoutSaved
    case workoutDiscarded
}

final class WorkoutSummaryCoordinator: Coordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var onWorkoutSaved: (() -> Void)?
    var onWorkoutDiscarded: (() -> Void)?
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    private let factory: WorkoutSummaryCoordinatorFactory
    private let workoutID: String
    private let stats: WorkoutStats
    
    init(navigationController: UINavigationController, factory: WorkoutSummaryCoordinatorFactory, workoutID: String, stats: WorkoutStats) {
        self.navigationController = navigationController
        self.factory = factory
        self.workoutID = workoutID
        self.stats = stats
    }
    
    
    func start() {
        let summaryVC = factory.makeWorkoutSummaryVC(workoutID: workoutID, stats: stats)
        
        summaryVC.onDeinit = { [weak self] in
            guard let self else { return }
            self.finishDelegate?.coordinatorDidFinish(childCoordinator: self)
        }
        
        summaryVC.didSendEventClosure = { [weak self] event in
            self?.handle(event)
        }
        
        navigationController.pushViewController(summaryVC, animated: true)
    }
    
    private func handle(_ event: WorkoutSummaryEvent) {
         switch event {
         case .workoutSaved:
             onWorkoutSaved?()
         case .workoutDiscarded:
             onWorkoutDiscarded?()
         }
     }
}
