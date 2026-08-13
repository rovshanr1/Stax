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
    
    private let userDefaults: UserDefaults
    
    private let minimumDisplayDuration: TimeInterval = 1.0
    
    init(firebaseSyncService: FirebaseSyncServiceInterface, syncManager: SyncManagerInterface, workoutRepo: DataRepository<Workout>, dataSeeder: DataSeederProtocol, userDefaults: UserDefaults = .standard) {
        self.firebaseSyncService = firebaseSyncService
        self.syncManager = syncManager
        self.workoutRepo = workoutRepo
        self.dataSeeder = dataSeeder
        self.userDefaults = userDefaults
        
        self.output = .init(syncCompleted: .init())
        
        startInitialization()
    }
    
    private func startInitialization(){
        Task{
            let startTime = Date()
            
            await dataSeeder.seedExercise()
            await cleanAbandonedWorkouts()
            await performSync()
            
            await enforceMinimumDisplayDuration(since: startTime)
            
            output.syncCompleted.send()
        }
    }
    
    //MARK: - Minimum Duration Enforcement
    private func enforceMinimumDisplayDuration(since startTime: Date) async{
        let elapsed = Date().timeIntervalSince(startTime)
        let remaining = minimumDisplayDuration - elapsed
        
        guard remaining > 0 else { return }
        
        try? await Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
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
        if userDefaults.bool(forKey: UserDefaultsKeys.isSeededFromFirebase) == true {
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
                    
                    userDefaults.set(true, forKey: UserDefaultsKeys.isSeededFromFirebase)
                case .failure(let error):
                    print(error.localizedDescription)
                }
                
                continuation.resume()
            }
        }
        
        
        
    }
    
}
