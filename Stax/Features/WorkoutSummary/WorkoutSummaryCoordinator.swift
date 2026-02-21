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
    case syncButtpPressed
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
    private let stats: WorkoutStats
    
    init(navigationController: UINavigationController, context: NSManagedObjectContext, workout: Workout, stats: WorkoutStats) {
        self.navigationController = navigationController
        self.context = context
        self.workout = workout
        self.stats = stats
    }
    
    func start() {
        let summaryVC = WorkoutSummaryVC()
        
        //Repo injection
        let repo = DataRepository<Workout>(context: context)
        
        //VM Injection 
        self.vm = WorkoutSummaryViewModel(workout: workout, workoutRepository: repo, stats: stats)
        
        summaryVC.viewModel = self.vm
        
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
        case .syncButtpPressed:
            self.showSyncHealthVC()
        }
    }
    
    
    private func showSyncHealthVC() {
        let currentState = vm?.output.isHealthKitSyncEnabled.value ?? false
        
        let sheetNav = SyncWithSheet(initialSyncState: currentState)
        sheetNav.modalPresentationStyle = .pageSheet
        
        if let sheet = sheetNav.sheetPresentationController{
            sheet.detents = [ .custom(identifier: .init("small"), resolver: { context in
                return 150
            }) ]
            
            sheet.prefersGrabberVisible = true
        }
        
        
        sheetNav.syncWithHealth = {[weak self] (isEnable, completion) in
           guard let self else {return}
            
            self.vm?.input.toggleHealthKitSync.send(isEnable)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
             let actualState = self.vm?.output.isHealthKitSyncEnabled.value ?? false
                completion(actualState)
            }
        }
        
        navigationController.present(sheetNav, animated: true)
    }
}
