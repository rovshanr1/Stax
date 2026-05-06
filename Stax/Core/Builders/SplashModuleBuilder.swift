//
//  SplashModuleBuilder.swift
//  Stax
//
//  Created by Rovshan Rasulov on 06.05.26.
//

import UIKit

final class SplashModuleBuilder{
    static func build(container: AppDIContainer) -> (UIViewController, SplashVM){
        let firebaseService = container.sharedFirebaseService
        let syncManager = container.sharedSyncManager
        
        let splashVM = SplashVM(firebaseSyncService: firebaseService, syncManager: syncManager)
        let splashVC = SplashVC(vm: splashVM)
        
        return (splashVC, splashVM)
    }
}
