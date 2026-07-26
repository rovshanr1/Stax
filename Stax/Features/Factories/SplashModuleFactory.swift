//
//  SplashModuleFactory.swift
//  Stax
//
//  Created by Rovshan Rasulov on 06.05.26.
//

import UIKit

final class SplashModuleFactory{
    static func build(container: AppDependencies) -> (UIViewController, SplashVM){
        let firebaseService = container.sharedFirebaseService
        let syncManager = container.sharedSyncManager
        let dataSeeder = container.dataSeeder
        
        let splashVM = SplashVM(firebaseSyncService: firebaseService, syncManager: syncManager, workoutRepo: container.genericWorkoutRepo, dataSeeder: dataSeeder)
        let splashVC = SplashVC(vm: splashVM)
        
        return (splashVC, splashVM)
    }
}
