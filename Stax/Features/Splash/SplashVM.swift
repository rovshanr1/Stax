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
        let syncCompleted: CurrentValueSubject<Bool, Never>
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
    
    private var initializationTask: Task<Void, Never>?
    
    init(firebaseSyncService: FirebaseSyncServiceInterface, syncManager: SyncManagerInterface, workoutRepo: DataRepository<Workout>, dataSeeder: DataSeederProtocol, userDefaults: UserDefaults = .standard) {
        self.firebaseSyncService = firebaseSyncService
        self.syncManager = syncManager
        self.workoutRepo = workoutRepo
        self.dataSeeder = dataSeeder
        self.userDefaults = userDefaults
        
        self.output = .init(syncCompleted: .init(false))
        
        startInitialization()
    }
    
    private func startInitialization() {
        initializationTask = Task { [weak self] in
            guard let self else { return }

            await dataSeeder.seedExercise()
            await cleanAbandonedWorkouts()
            await performSync()

            output.syncCompleted.send(true)
        }
    }
    
    deinit { initializationTask?.cancel() }
    
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
        
        do {
            let cloudWorkouts = try await firebaseSyncService.fetchInitialWorkoutsFromCloud()
            
            for workout in cloudWorkouts {
                syncManager.saveCloudWorkoutToLocal(cloudWorkout: workout)
            }
            
            userDefaults.set(true, forKey: UserDefaultsKeys.isSeededFromFirebase)
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
