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
    case discardWokrout
}

final class WorkoutSummaryCoordinator: Coordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    //Closures
    var onWorkoutSaved: (() -> Void)?
    var onWorkoutDiscarded: (() -> Void)?
    
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
        
        vm?.output.finished
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                guard let self else {return}
                self.onWorkoutSaved?()
            })
            .store(in: &cancellables)
        
        
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
            vm?.input.saveWorkout.send()
        case .syncButtpPressed:
            showSyncHealthVC()
        case .discardWokrout:
            discardedWorkout()
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
        
        
        sheetNav.syncWithHealth = {[weak self] isEnable in
           guard let self else {return}
            self.vm?.input.toggleHealthKitSync.send(isEnable)
        }
        
        vm?.output.isHealthKitSyncEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak sheetNav] isEnabled in
                guard let sheetNav else {return}
                sheetNav.forceUpdateState(isEnabled)
            }
            .store(in: &cancellables)
        
        navigationController.present(sheetNav, animated: true)
    }
    
    private func discardedWorkout() {
        guard let currentVC = navigationController.topViewController else {return}
        
        AlertManager.showConfirmationAlert(on: currentVC,
                                           title: nil,
                                           message: "Are you sure you want to discard this wokrout?",
                                           confirmTitle: "Discard Workout",
                                           cancelTitle: "Cancel") { [weak self ] in
            guard let self else {return}
            if let woroutToDelete = self.vm?.workout{
                self.context.delete(woroutToDelete)
                try? self.context.save()
                
                onWorkoutDiscarded?()
            }
        }
        
    }
}
