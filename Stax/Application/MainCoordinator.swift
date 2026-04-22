//
//  MainCoordinator.swift
//  Stax
//
//  Created by Rovshan Rasulov on 28.11.25.
//

import UIKit
import CoreData
import Combine
import FirebaseAuth

//MARK: - MainCoordinator
protocol MainCoordinatorProtocol: Coordinator{
    func authFlow()
    func showMainFlow()
    func showSplashView()
}


class MainCoordinator: MainCoordinatorProtocol{
    weak var finishDelegate: CoordinatorFinishDelegate? = nil
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var type: CoordinatorType { return .app }
    let context: NSManagedObjectContext
    var cancellables: Set<AnyCancellable> = []
    
    init(_ navigationController: UINavigationController, context: NSManagedObjectContext) {
        self.navigationController = navigationController
        self.context = context
    }
    
    func start() {
        
        handleIsFirshLaunchCompleted()
        
        if Auth.auth().currentUser != nil{
            showSplashView()
        }else{
            authFlow()
        }
    }
    
    func showSplashView(){
        let workoutRepo = DataRepository<Workout>(context: context)
        let exerciseRepo = DataRepository<WorkoutExercise>(context: context)
        let setRepo = DataRepository<WorkoutSet>(context: context)
        let exerciseDefRepo = DataRepository<Exercise>(context: context)
        
        let firebaseService = FirebaseSyncService()
        let syncManager = SyncManager(workoutRepo: workoutRepo,
                                      exerciseRepo: exerciseRepo,
                                      setRepo: setRepo,
                                      exercise: exerciseDefRepo)
        
        let splashVM = SplashVM(firebaseSyncService: firebaseService, syncManager: syncManager)
        let splashVC = SplashVC(vm: splashVM)
        
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.setViewControllers([splashVC], animated: false)
        
        splashVM.output.syncCompleted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else { return }
                self.showMainFlow()
            }
            .store(in: &cancellables)
    }
    
    func authFlow() {
        let authCoordinator = AuthCoordinator(navigationController)
        authCoordinator.finishDelegate = self
        authCoordinator.start()
        navigationController.setNavigationBarHidden(true, animated: false)
        childCoordinators.append(authCoordinator)
    }
    
    func showMainFlow() {
        let tabCoordinator = TabCoordinator(navigationController, context: context)
        tabCoordinator.finishDelegate = self
        navigationController.setNavigationBarHidden(true, animated: false)
        tabCoordinator.start()
        childCoordinators.append(tabCoordinator)
    }
    
    func handleIsFirshLaunchCompleted() {
        let defaults = UserDefaults.standard
        
        if defaults.bool(forKey: "isFirshLaunchCompleted") == false{
            
            try? Auth.auth().signOut()
            
            defaults.set(true, forKey: "isFirshLaunchCompleted")
        }
    }
}


//MARK: - CoordinatorFinishDelegate
extension MainCoordinator: CoordinatorFinishDelegate{
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter({ $0 !== childCoordinator})
        switch childCoordinator.type {
        case .tab:
            navigationController.viewControllers.removeAll()
            authFlow()
        case .auth:
            navigationController.viewControllers.removeAll()
            showSplashView()
        default:
            break
        }
    }
}
