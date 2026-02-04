//
//  WorkoutSummaryCoordinator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 31.01.26.
//

import UIKit
import Combine
import CoreData
enum WorkoutSummaryEvent{
    case saveWorkout
}

final class WorkoutSummaryCoordinator: Coordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    var type: CoordinatorType { .workoutSummary}
    
    let context: NSManagedObjectContext
    
    var cancellables: Set<AnyCancellable> = []
    
    var vm: WorkoutSummaryViewModel?
    
    private let workout: Workout
    
    init(navigationController: UINavigationController, context: NSManagedObjectContext, workout: Workout) {
        self.navigationController = navigationController
        self.context = context
        self.workout = workout
    }
    
    func start() {
        let summaryVC = WorkoutSummaryVC()
        
        //Repo injection
        let repo = DataRepository<Workout>(context: context)
        
        //VM Injection 
        self.vm = WorkoutSummaryViewModel(workout: workout, workoutRepository: repo)
        
    
        summaryVC.onDeinit = {[weak self] in
            guard let self else {return}
            self.finishDelegate?.coordinatorDidFinish(childCoordinator: self)
        }
        
        summaryVC.didSendEventClosure = { [weak self] event in
            self?.handle(event)
        }
        
        navigationController.pushViewController(summaryVC, animated: true)
    }
    
    private func handle(_ event: WorkoutSummaryEvent) {
        switch event {
        case .saveWorkout:
            print("save button tapped")
//            vm?.input.saveWorkout.send()
        }
    }
    
    
    private func handleSaveWorkout() {
        
    }
}
