//
//  HomeCoordinator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 01.12.25.
//

import UIKit
import Combine

enum HomeEvent{
    case presentShareSheet(text: String)
    case presentWorkoutDetails(id: String)
    case startEmptyWorkout
    case editWorkout(id: String)
}


final class HomeCoordinator: Coordinator{
   
    //Coordinator
    var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController

    
    //Factory
    private let factory: HomeCoordinatorFactory
    
    init(navigationController: UINavigationController, factory: HomeCoordinatorFactory) {
        self.navigationController = navigationController
        self.factory = factory
    }
    
    func start() {
        let homeVC = factory.makeHomeViewController()
        
        homeVC.didSendEventClosure = { [weak self] event in
            self?.handle(event)
        }
        
        navigationController.setViewControllers([homeVC], animated: false)
    }
    
    private func handle(_ event: HomeEvent){
        switch event{
        case .presentShareSheet(text: let text):
            self.handleShareSheet(with: text)
        case .presentWorkoutDetails(id: let id):
            handleWorkoutDetailView(for: id)
        case .startEmptyWorkout:
            handleWorkoutSession(for: nil)
        case .editWorkout(id: let id):
            handleWorkoutSession(for: id)
        }
    }
    
    private func handleShareSheet(with text: String){
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        navigationController.present(activityVC, animated: true)
    }
    
    private func handleWorkoutSession(for id: String?){
        let modalNav = UINavigationController()
        modalNav.modalPresentationStyle = .fullScreen
        
        let sessionCoordinator = factory.makeWorkoutSessionCoordinator(navigationController: modalNav, workoutId: id)
        
        sessionCoordinator.finishDelegate = self
        
        self.childCoordinators.append(sessionCoordinator)
        sessionCoordinator.start()
        
        navigationController.present(modalNav, animated: true)
    }
    
    private func handleWorkoutDetailView(for id: String){
        let workoutDetailCoordinator = factory.makeWorkoutDetailCoordinator(navigationController: navigationController, workoutId: id)
        
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
