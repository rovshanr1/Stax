//
//  SplashVM.swift
//  Stax
//
//  Created by Rovshan Rasulov on 10.04.26.
//

import Foundation
import Combine

@MainActor
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
    
    private var initializationTask: Task<Void, Never>?
    
    init(firebaseSyncService: FirebaseSyncServiceInterface, syncManager: SyncManagerInterface, workoutRepo: DataRepository<Workout>, dataSeeder: DataSeederProtocol, userDefaults: UserDefaults = .standard) {
        self.firebaseSyncService = firebaseSyncService
        self.syncManager = syncManager
        self.workoutRepo = workoutRepo
        self.dataSeeder = dataSeeder
        self.userDefaults = userDefaults
        
        self.output = .init(syncCompleted: .init(false))
    }
    
    func start() {
        guard initializationTask == nil else { return }
        
        initializationTask = Task{
            await initialize()
        }
    }
    
    private func initialize() async {
        await dataSeeder.seedExercise()
        await cleanAbandonedWorkouts()
        await performSync()
        
        output.syncCompleted.send(true)
    }
    
    //MARK: - Garbage Collection
    private func cleanAbandonedWorkouts() async{
        let workouts = await workoutRepo.fetchAllAsync()
        let abandoned = workouts.filter { ($0.name ?? "").isEmpty && $0.duration == 0 }

        for draft in abandoned{
            if let id = draft.id?.uuidString{
                await workoutRepo.deleteAsync(id)
            }
        }
        
        //TODO: - Cleaning this code
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
