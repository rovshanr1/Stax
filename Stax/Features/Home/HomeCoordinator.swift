//
//  HomeCoordinator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 01.12.25.
//

import UIKit
import Combine

enum HomeEvent{
    case workoutMenuButtonTapped(id: String)
    case presentShareSheet(text: String)
    case presentWorkoutDetails(id: String)
}


final class HomeCoordinator: Coordinator{
   
    //Coordinator
    var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController

    
    //Container
    let appDIContainer: AppDIContainer
    
    var vm: HomeVM?
    
    init(navigationController: UINavigationController, appDIContainer: AppDIContainer) {
        self.navigationController = navigationController
        self.appDIContainer = appDIContainer
        
        self.vm = HomeVM(workoutRepo: appDIContainer.sharedWorkoutRepo,
                         shareService: appDIContainer.shareService
        )
    }
    
    func start() {
        let homeVC = HomeVC()
    
        homeVC.vm = self.vm
        homeVC.navigationItem.largeTitleDisplayMode = .always
        
        homeVC.didSendEventClosure = { [weak self] event in
            self?.handle(event)
        }
        
        navigationController.setViewControllers([homeVC], animated: false)
    }
    
    private func handle(_ event: HomeEvent){
        switch event{
        case .workoutMenuButtonTapped(let id):
            self.showMoreSheet(for: id)
        case .presentShareSheet(text: let text):
            self.handleShareSheet(with: text)
        case .presentWorkoutDetails(id: let id):
            handleWorkoutDetailView(for: id)
        }
    }
    
   
    
    private func showMoreSheet(for id: String){
        let sheetNav = WorkoutMenuViewController()
        sheetNav.modalPresentationStyle = .pageSheet
        
        if let sheet = sheetNav.sheetPresentationController{
            sheet.detents = [.custom(resolver: { _ in 190})]
            sheet.prefersGrabberVisible = true
        }
        
        sheetNav.onActionSelected = {[weak self] action in
            self?.handleWorkoutMenu(action, for: id)
        }
         
        navigationController.present(sheetNav, animated: true)
    }
    
    private func handleWorkoutMenu(_ action: WorkoutMenuViewController.Action, for id: String){
        navigationController.dismiss(animated: true) { [weak self] in
            guard let self else {return}
            
            switch action{
            case .edit:
                self.handleEditWorkout(for: id)
            case .share:
              self.vm?.input.shareWorkout.send(id)
            case .delete:
                self.vm?.input.deleteWorkout.send(id)
            }
        }
    }
    
    private func handleShareSheet(with text: String){
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        navigationController.present(activityVC, animated: true)
    }
    
    private func handleEditWorkout(for id: String){
        let modalNav = UINavigationController()
        modalNav.modalPresentationStyle = .fullScreen
        
        let sessionCoordinator = WorkoutSessionCoordinator(modalNav, appDIContainer: appDIContainer, workoutId: id)
        
        sessionCoordinator.finishDelegate = self
        
        self.childCoordinators.append(sessionCoordinator)
        sessionCoordinator.start()
        
        navigationController.present(modalNav, animated: true)
    }
    
    private func handleWorkoutDetailView(for id: String){
        let workoutDetailCoordinator = WorkoutDetailCoordinator(navigationController: navigationController, appDIContainer: appDIContainer, workoutID: id)
        
        workoutDetailCoordinator.finishDelegate = self
        childCoordinators.append(workoutDetailCoordinator)
        workoutDetailCoordinator.start()
    }
}

extension HomeCoordinator: CoordinatorFinishDelegate{
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter({$0 !== childCoordinator})
    }
    
}
