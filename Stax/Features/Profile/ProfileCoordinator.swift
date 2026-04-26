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
    case showWorkoutMenu(id: String)
    case presentShareSheet(text: String)
    case presentWorkoutDetails(id: String)
    case presentSettings
    case presentEditProfile
    case profilePhotoTapped
}

final class ProfileCoordinator: Coordinator{
    var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    var type: CoordinatorType { .page }
    
    //Services
    private var workoutRepo: WorkoutRepositoryProtocol
    private var userManager: UserManager
    
    private let context: NSManagedObjectContext
    private var vm: ProfileVM
    
   
    
    init(_ navigationController: UINavigationController, workoutRepo: WorkoutRepositoryProtocol, context: NSManagedObjectContext, userManager: UserManager) {
        self.navigationController = navigationController
        self.workoutRepo = workoutRepo
        self.context = context
        self.vm = ProfileVM(workoutRepo: workoutRepo, userManger: userManager)
        self.userManager = userManager
    }
    
    func start() {
        let profileVC = ProfileVC(viewModel: vm)
        
        profileVC.didSendEventClosure = { [weak self] event in
            self?.handle(event)
        }
        
        profileVC.navigationItem.largeTitleDisplayMode = .always
        navigationController.setViewControllers([profileVC], animated: false)
    }
    
    private func handle(_ event: ProfileEvent) {
        switch event {
        case .showWorkoutMenu(let id):
            showWorkoutMenu(for: id)
        case .presentShareSheet(text: let text):
            handleShareSheet(with: text)
        case .presentWorkoutDetails(id: let id):
            handleWorkoutDetailView(for: id)
        case .presentSettings:
            print("settings tapped")
        case .presentEditProfile:
            handleEditProfile()
        case .profilePhotoTapped:
            handleEditProfile()
        }
    }
    
    private func showWorkoutMenu(for id: String){
        let sheetNav = WorkoutMenuViewController()
        sheetNav.modalPresentationStyle = .pageSheet
        
        if let sheet = sheetNav.sheetPresentationController{
            sheet.detents = [.custom(resolver: {_ in 190})]
            sheet.prefersGrabberVisible = true
        }
        
        sheetNav.onActionSelected = { [weak self] action in
            self?.handleWorkoutMenuEvent(action, for: id)
        }
        
        navigationController.present(sheetNav, animated: true)
    }
    
 
    //MARK: - Handle Menu Events
    private func handleWorkoutMenuEvent(_ action: WorkoutMenuViewController.Action, for id: String) {
        navigationController.dismiss(animated: true){ [weak self] in
            guard let self else {return}
            
            switch action {
            case .edit:
                self.handleEditWorkout(for: id)
            case .share:
                self.vm.input.shareWorkout.send(id)
            case .delete:
                self.vm.input.deleteWokrout.send(id)
            }
        }
    }
    
    
    private func handleEditWorkout(for id: String) {
        let modalNav = UINavigationController()
        modalNav.modalPresentationStyle = .fullScreen
        
        let sessionCoordinator = WorkoutSessionCoordinator(modalNav, context: context, workoutId: id)
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
        let workoutDetailCoordinator = WorkoutDetailCoordinator(navigationController: navigationController, workoutID: id, workoutRepo: workoutRepo)
        
        workoutDetailCoordinator.finishDelegate = self
        childCoordinators.append(workoutDetailCoordinator)
        workoutDetailCoordinator.start()
    }
    
    private func handleEditProfile(){
        guard let currentUser = vm.output.userInfo.value else {
            return
        }
        
        let editProfileCoordinator = EditProfileCoordinator(navigationController: navigationController, userModel: currentUser, userManager: userManager)
        
        editProfileCoordinator.finishDelegate = self
        childCoordinators.append(editProfileCoordinator)
        editProfileCoordinator.start()
    }
  
}

extension ProfileCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter({$0 !== childCoordinator})
    }
}
