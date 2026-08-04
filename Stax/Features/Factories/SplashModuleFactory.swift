//
//  SplashModuleFactory.swift
//  Stax
//
//  Created by Rovshan Rasulov on 06.05.26.
//

import UIKit

protocol SplashModuleFactoryProtocol{
    func makeSplashModule() -> SplashVC
}

struct SplashModuleFactory: SplashModuleFactoryProtocol{
    let appDIContainer: AppDependencies
    
    init(appDIContainer: AppDependencies) {
        self.appDIContainer = appDIContainer
    }
    
    func makeSplashModule() -> SplashVC {
       
        let splashVM = SplashVM(firebaseSyncService: appDIContainer.sharedFirebaseService, syncManager: appDIContainer.sharedSyncManager, workoutRepo: appDIContainer.genericWorkoutRepo, dataSeeder: appDIContainer.dataSeeder
        )
        let splashVC = SplashVC(vm: splashVM)
        
        return splashVC
    }
    
    
}
