//
//  EditAccountCoordinator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 16.05.26.
//

import UIKit
import Combine

final class EditAccountCoordinator: Coordinator{
    var finishDelegate: (CoordinatorFinishDelegate)?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    
    init(navigationController: UINavigationController){
        self.navigationController = navigationController
    }
    
    func start() {
        
    }
    
    
}
