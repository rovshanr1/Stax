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
    private let dataSeeder: DataSeederProtocol
    
    private let workoutRepo: DataRepository<Workout>
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(firebaseSyncService: FirebaseSyncServiceInterface, syncManager: SyncManagerInterface, workoutRepo: DataRepository<Workout>, dataSeeder: DataSeederProtocol) {
        self.firebaseSyncService = firebaseSyncService
        self.syncManager = syncManager
        self.workoutRepo = workoutRepo
        self.dataSeeder = dataSeeder
        
        self.output = .init(syncCompleted: .init())
        
        startInitialization()
    }
    
    private func startInitialization(){
        Task{
            await dataSeeder.seed()
            
            await cleanAbandonedWorkouts()
            
            await performSync()
        }
    }
    
    //MARK: - Garbage Collection
    private func cleanAbandonedWorkouts() async{
        let workouts = await workoutRepo.fetchAllAsync()
        let abandoned = workouts.filter { $0.name == nil || $0.name == ""   }
        
        for draft in abandoned{
            if let id = draft.id?.uuidString{
                await workoutRepo.deleteAsync(id)
            }
        }
        
        if !abandoned.isEmpty {
            print("SplashVM: \(abandoned.count) abandoned workout(s) cleaned up.")
        }
    }
    
    
    //MARK: - FirebaseSync
    private func performSync() async{
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "isSeededFromFirebase") == true {
            output.syncCompleted.send()
            return
        }
        
        await withCheckedContinuation { continuation in
            firebaseSyncService.fetchInitialWorkoutsFromCloud { [weak self] result in
                guard let self else {
                    continuation.resume()
                    return
                }
                
                switch result{
                case .success(let cloudWorkouts):
                    for workout in cloudWorkouts{
                        self.syncManager.saveCloudWorkoutToLocal(cloudWorkout: workout)
                    }
                    
                    defaults.set(true, forKey: "isSeededFromFirebase")
                    output.syncCompleted.send()
                case .failure(let error):
                    print(error.localizedDescription)
                    output.syncCompleted.send()
                }
                
                continuation.resume()
            }
        }
        
        
        
    }
    
}
