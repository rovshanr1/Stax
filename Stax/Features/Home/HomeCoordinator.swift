//
//  HomeCoordinator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 01.12.25.
//

import UIKit
import CoreData

enum HomeEvent{
    case moreButtonTapped(id: String)
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
        case .moreButtonTapped(let id):
            self.showMoreSheet(for: id)
        }
    }
    
    private func showMoreSheet(for id: String){
        let sheetNav = MoreSheetViewController()
        sheetNav.modalPresentationStyle = .pageSheet
        
        if let sheet = sheetNav.sheetPresentationController{
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        
        navigationController.present(sheetNav, animated: true)
    }
}
