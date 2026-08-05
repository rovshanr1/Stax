//
//  MainTabBarController.swift
//  Stax
//
//  Created by Rovshan Rasulov on 28.11.25.
//

import UIKit

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

    //Container
    private let dependencies: AppDependencies
    
    
    
    init(_ navigationController: UINavigationController, appDIContainer: AppDependencies) {
        self.navigationController = navigationController
        self.tabBarController = MainTabBarController()
        self.dependencies = appDIContainer
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
        navController.tabBarItem = UITabBarItem.init(title: nil, image: page.icon, selectedImage: page.selectedIcon)
        
        switch page {
        case .home:
            let factory = DefaultHomeModuleFactory(dependency: dependencies)
            
            let homeCoordinator = HomeCoordinator(navigationController: navController, factory: factory)
            homeCoordinator.finishDelegate = self
            childCoordinators.append(homeCoordinator)
            homeCoordinator.start()
        case .workout:
            let exerciseCoordinator = WorkoutCoordinator(navController, appDIContainer: dependencies)
            exerciseCoordinator.finishDelegate = self
            childCoordinators.append(exerciseCoordinator)
            exerciseCoordinator.start()
        case .profile:
            let factory = DefaultProfileModuleFactory(dependency: dependencies)
            
            let profileCoordinator = ProfileCoordinator(navController, factory: factory)
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
        
        self.finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}
