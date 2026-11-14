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
    private let userDefaults: UserDefaults
    
    private let cloudFetchTimeout: TimeInterval = 8
    
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
        cleanAbandonedWorkouts()
        await restoreFromCloudIfNeeded()
        output.syncCompleted.send(true)
    }
    
    private func cleanAbandonedWorkouts() {
        let abandoned = workoutRepo.fetch().filter {
            ($0.name ?? "").isEmpty && $0.duration == 0
        }
        guard !abandoned.isEmpty else { return }
 
        abandoned.forEach { workoutRepo.deleteNow($0) }
 
        do {
            try workoutRepo.saveNow()
            print("SplashVM: \(abandoned.count) abandoned workout(s) cleaned up.")
        } catch {
            workoutRepo.rollback()
            print("SplashVM: cleanup failed: \(error)")
        }
    }
    
    
    //MARK: - FirebaseSync
    private func restoreFromCloudIfNeeded() async {
        guard !userDefaults.bool(forKey: UserDefaultsKeys.isSeededFromFirebase) else { return }
        guard let fetched = await fetchCloudWorkoutsWithTimeout() else { return }
 
        do {
            let result = try syncManager.restoreWorkouts(fetched.workouts)
 

            let isComplete = fetched.undecodableCount == 0 && result.missingExerciseDefinitions == 0
            if isComplete {
                userDefaults.set(true, forKey: UserDefaultsKeys.isSeededFromFirebase)
            }
 
            print("SplashVM: restored \(result.restoredWorkouts), skipped \(result.skippedWorkouts), "
                  + "undecodable \(fetched.undecodableCount), missing definitions \(result.missingExerciseDefinitions)")
        } catch {
            print("SplashVM: cloud restore failed, will retry next launch: \(error)")
        }
    }
    
    private func fetchCloudWorkoutsWithTimeout() async -> CloudFetchResult? {
        let gate = ContinuationGate()
        let service = firebaseSyncService
        let timeout = cloudFetchTimeout
 
        return await withCheckedContinuation { (continuation: CheckedContinuation<CloudFetchResult?, Never>) in
            let timeoutTask = Task {
                try? await Task.sleep(for: .seconds(timeout))
                guard !Task.isCancelled, gate.tryClose() else { return }
                print("SplashVM: cloud fetch timed out")
                continuation.resume(returning: nil)
            }
 
            Task {
                do {
                    let result = try await service.fetchInitialWorkoutsFromCloud()
                    guard gate.tryClose() else { return }
                    timeoutTask.cancel()
                    continuation.resume(returning: result)
                } catch {
                    guard gate.tryClose() else { return }
                    timeoutTask.cancel()
                    print("SplashVM: cloud fetch failed: \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
}

private final class ContinuationGate {
    private var isOpen = true
 
    func tryClose() -> Bool {
        guard isOpen else { return false }
        isOpen = false
        return true
    }
}
