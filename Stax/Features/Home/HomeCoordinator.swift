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
        let repo = DataRepository<Workout>(context: context)
        
        //VM injection
        self.vm = HomeVM(workoutRepo: repo)
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
                print("edit")
            case .share:
                print("share")
            case .delete:
                self.vm?.input.deleteWorkout.send(id)
            }
        }
    }
}
