//
//  MainTabBarController.swift
//  Stax
//
//  Created by Rovshan Rasulov on 28.11.25.
//

import UIKit
import CoreData

protocol TabCoordinatorProtocol: Coordinator{
    var tabBarController: UITabBarController  {get set}
    
    func selectedPage(_ page: TabBarPage)
    func setSelectedIndex(_ page: TabBarPage)
    func currentPage() -> TabBarPage?
}

class TabCoordinator: NSObject, Coordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    var tabBarController: UITabBarController
    let context: NSManagedObjectContext
    
    var type: CoordinatorType { .tab }
    
    init(_ navigationController: UINavigationController, context: NSManagedObjectContext) {
        self.navigationController = navigationController
        self.tabBarController = .init()
        self.context = context
    }
    
    deinit{
        print("TabCoordinator deinit")
    }
  
    func start() {
        //Let's define which pages do we want to add into tab bar
        let pages: [TabBarPage] = TabBarPage.allCases.sorted(by: {$0.rawValue < $1.rawValue})
        
        //Initialization of ViewControllers or these pages
        let controllers: [UINavigationController] = pages.map({ getTabController($0) })
        
        prepareTabBarController(withTabControllers: controllers)
        
    }
    
    
    private func prepareTabBarController(withTabControllers tabControllers: [UINavigationController]) {
        ///Set delegate for UITabBarCOntroller
        tabBarController.delegate = self
        ///Addign page's controllers
        tabBarController.setViewControllers(tabControllers, animated: false)
        ///Let set index
        tabBarController.selectedIndex = TabBarPage.home.rawValue
        ///Styling
        tabBarController.tabBar.tintColor = .activeItems
        
        ///attach tabBarController to navigation controller associate
        navigationController.viewControllers = [tabBarController]
    }
    
    private func getTabController(_ page: TabBarPage) -> UINavigationController{
        let navController = UINavigationController()
        navController.navigationBar.prefersLargeTitles = true
        navController.tabBarItem = UITabBarItem.init(title: page.title, image: page.icon, selectedImage: page.selectedIcon)
        
        switch page {
        case .home:
            let homeCoordinator = HomeCoordinator(navController)
            homeCoordinator.finishDelegate = self
            childCoordinators.append(homeCoordinator)
            homeCoordinator.start()
        case .workout:
            let exerciseCoordinator = WorkoutCoordinator(navController, context: context)
            exerciseCoordinator.finishDelegate = self
            childCoordinators.append(exerciseCoordinator)
            exerciseCoordinator.start()
        case .profile:
            let profileCoordinator = ProfileCoordinator(navController)
            profileCoordinator.finishDelegate = self
            childCoordinators.append(profileCoordinator)
            profileCoordinator.start()
        }
        
        return navController
    }
    
    func currentPage() -> TabBarPage? {
        TabBarPage.allCases[tabBarController.selectedIndex]
    }
    
    func selectedPage(_ page: TabBarPage) {
        tabBarController.selectedIndex = page.rawValue
    }
    
    func setSelectedIndex(_ page: TabBarPage) {
        guard let index = TabBarPage.allCases.firstIndex(of: page) else { return }
        tabBarController.selectedIndex = index
    }
}


//MARK: - UITabBarControllerDelegate

extension TabCoordinator: UITabBarControllerDelegate{
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
}

//MARK: - CoordinatorDinishDelegate
extension TabCoordinator: CoordinatorFinishDelegate{
    func coordinatorDidFinish(childCoordinator coordinator: Coordinator) {
        childCoordinators = childCoordinators.filter({ $0 !== coordinator})
    }
}
