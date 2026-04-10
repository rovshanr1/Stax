//
//  SplashVM.swift
//  Stax
//
//  Created by Rovshan Rasulov on 10.04.26.
//

import Foundation
import Combine

final class SplashVM{
    struct Output{
        let syncCompleted: PassthroughSubject<Void, Never>
    }
    
    let output: Output
    
    //Services
    private let firebaseSyncService: FirebaseSyncServiceInterface
    private let syncManager: SyncManagerInterface
    
    init(firebaseSyncService: FirebaseSyncServiceInterface, syncManager: SyncManagerInterface) {
        self.firebaseSyncService = firebaseSyncService
        self.syncManager = syncManager
        
        self.output = .init(syncCompleted: .init())
        
        startInitialSync()
    }
    
    func startInitialSync(){
        let defaults = UserDefaults.standard
        
        if defaults.bool(forKey: "isSeededFromFirebase") == true{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.output.syncCompleted.send()
            })
            
            return
        }
        
        firebaseSyncService.fetchInitialWorkoutsFromCloud { [weak self] result in
            guard let self else { return }
            
            switch result{
            case .success(let cloudWorkouts):
                for workout in cloudWorkouts{
                    self.syncManager.saveCloudWorkoutToLocal(cloudWorkout: workout)
                }
                
                defaults.set(true, forKey: "isSeededFromFirebase")
                self.output.syncCompleted.send()
                
            case .failure(let error):
                print(error.localizedDescription)
                self.output.syncCompleted.send()
            }
        }
    }
   
}
