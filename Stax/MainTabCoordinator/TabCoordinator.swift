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
    func setSelectedPage(_ page: TabBarPage)
    func currentPage() -> TabBarPage?
}

class TabCoordinator: NSObject, Coordinator {
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    var tabBarController: UITabBarController
    
    var type: CoordinatorType { .tab }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.tabBarController = .init()
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
        tabBarController.setViewControllers(tabControllers, animated: true)
        ///Let set index
        tabBarController.selectedIndex = TabBarPage.home.rawValue
        ///Styling
        tabBarController.tabBar.isTranslucent = false
        
        ///attach tabBarController to navigation controller associate
        navigationController.viewControllers = [tabBarController]
        
        
    }
    
    private func getTabController(_ page: TabBarPage) -> UINavigationController{
        let navController = UINavigationController()
        navController.setNavigationBarHidden(true, animated: false)
        
        navController.tabBarItem = UITabBarItem.init(title: page.title, image: page.icon, selectedImage: page.selectedIcon)
        
        switch page {
        case .home:
            let homeVC = HomeVC()
            
            navController.pushViewController(homeVC, animated: true)
        case .exercise:
            let exerciseVC = ExerciseVC()
            
            navController.pushViewController(exerciseVC, animated: true)
            
        case .profile:
            let profileVC = ProfileVC()
            
            navController.pushViewController(profileVC, animated: true)
        }
        
        return navController
    }
    
    func currentPage() -> TabBarPage? {
        TabBarPage.allCases[tabBarController.selectedIndex]
    }
    
    func selectedPage(_ page: TabBarPage) {
        guard let index = TabBarPage.allCases.firstIndex(of: page) else { return }
        tabBarController.selectedIndex = index
    }
}


//MARK: - UITabBarControllerDelegate

extension TabCoordinator: UITabBarControllerDelegate{
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
}
