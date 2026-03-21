//
//  HomeCoordinator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 01.12.25.
//

import UIKit
import CoreData
import Combine

enum HomeEvent{
    case workoutMenuButtonTapped(id: String)
    case presentShareSheet(text: String)
}


final class HomeCoordinator: Coordinator{
   
    //Coordinator
    var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var type: CoordinatorType { .page }
    
    
    let context: NSManagedObjectContext
    var vm: HomeVM?
    
    init(navigationController: UINavigationController, context: NSManagedObjectContext) {
        self.navigationController = navigationController
        self.context = context
    }
    
    func start() {
        let homeVC = HomeVC()
        
        //Repo injection
        let genericRepo = DataRepository<Workout>(context: context)
        let workoutRepo = WorkoutRepository(genericRoository: genericRepo)
        let shareService = WorkoutTextShareService()
        
        //VM injection
        self.vm = HomeVM(workoutRepo: workoutRepo, shareService: shareService)
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
        
        let sessionCoordinator = WorkoutSessionCoordinator(modalNav, context: self.context, workoutId: id)
        
        sessionCoordinator.finishDelegate = self
        
        self.childCoordinators.append(sessionCoordinator)
        sessionCoordinator.start()
        
        navigationController.present(modalNav, animated: true)
    }
}

extension HomeCoordinator: CoordinatorFinishDelegate{
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter({$0 !== childCoordinator})
    }
    
}
