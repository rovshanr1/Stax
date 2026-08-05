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
    let dependency: AppDependencies
    
    init(appDIContainer: AppDependencies) {
        self.dependency = appDIContainer
    }
    
    func makeSplashModule() -> SplashVC {
       
        let splashVM = SplashVM(firebaseSyncService: dependency.sharedFirebaseService, syncManager: dependency.sharedSyncManager, workoutRepo: dependency.genericWorkoutRepo, dataSeeder: dependency.dataSeeder
        )
        let splashVC = SplashVC(vm: splashVM)
        
        return splashVC
    }
    
    
}
