//
//  ProfileCoordinator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 01.12.25.
//

import UIKit
import CoreData
import Combine

enum ProfileEvent{
    case presentShareSheet(text: String)
    case presentWorkoutDetails(id: String)
    case presentSettings
    case presentEditProfile
    case profilePhotoTapped
    case editWorkout(id: String)
}

final class ProfileCoordinator: Coordinator{
    var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    
    //Services
    private let factory: ProfileCoordinatorFactory
    
   
    
    init(_ navigationController: UINavigationController, factory: ProfileCoordinatorFactory) {
        self.navigationController = navigationController
        self.factory = factory

    }
    
    func start() {
        let profileVC = factory.makeProfileViewController()
        
        profileVC.didSendEventClosure = { [weak self] event in
            self?.handle(event)
        }
        
        profileVC.navigationItem.largeTitleDisplayMode = .always
        navigationController.setViewControllers([profileVC], animated: false)
    }
    
    private func handle(_ event: ProfileEvent) {
        switch event {
        case .presentShareSheet(text: let text):
            handleShareSheet(with: text)
        case .presentWorkoutDetails(id: let id):
            handleWorkoutDetailView(for: id)
        case .presentSettings:
            handleSettings()
        case .presentEditProfile:
            handleEditProfile()
        case .profilePhotoTapped:
            handleEditProfile()
        case .editWorkout(id: let id):
            handleEditWorkout(for: id)
        }
    }
    
    
    private func handleEditWorkout(for id: String) {
        let modalNav = UINavigationController()
        modalNav.modalPresentationStyle = .fullScreen
        
        let sessionCoordinator = factory.makeWorkoutSessionCoordinator(navigationController: modalNav, workoutID: id)
        sessionCoordinator.finishDelegate = self
        
        self.childCoordinators.append(sessionCoordinator)
        sessionCoordinator.start()
        
        navigationController.present(modalNav, animated: true)
    }
    
    private func handleShareSheet(with text: String){
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        navigationController.present(activityVC, animated: true)
    }
    
    private func handleWorkoutDetailView(for id: String){
        let workoutDetailCoordinator = factory.makeWorkoutDetailCoordinator(navigationController: navigationController, workoutID: id)
        
        workoutDetailCoordinator.finishDelegate = self
        childCoordinators.append(workoutDetailCoordinator)
        workoutDetailCoordinator.start()
    }
    
    private func handleEditProfile(){
   
        let editProfileCoordinator = factory.makeEditProfileCoordinator(navigationController: navigationController)
        
        editProfileCoordinator.finishDelegate = self
        childCoordinators.append(editProfileCoordinator)
        editProfileCoordinator.start()
    }
    
    private func handleSettings(){
        let settingsCoordinator = factory.makeSettingsCoordinator(navigationController: navigationController)
        
        settingsCoordinator.finishDelegate = self
        settingsCoordinator.settingsDelegate = self
        
        childCoordinators.append(settingsCoordinator)
        settingsCoordinator.start()
    }
  
}

extension ProfileCoordinator: CoordinatorFinishDelegate, SettingsCoordinatorDelegate {
    func settingsCoordinatorDidLogout() {
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
    
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter({$0 !== childCoordinator})
    }
}
