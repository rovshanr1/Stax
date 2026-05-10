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
    
    private let workoutRepo: DataRepository<Workout>
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(firebaseSyncService: FirebaseSyncServiceInterface, syncManager: SyncManagerInterface, workoutRepo: DataRepository<Workout>) {
        self.firebaseSyncService = firebaseSyncService
        self.syncManager = syncManager
        self.workoutRepo = workoutRepo
        
        self.output = .init(syncCompleted: .init())
        
        startInitialization()
    }
    
    private func startInitialization(){
        cleanAbandonedWorkouts()
        performSync()
    }
    
    //MARK: - Garbage Collection
    private func cleanAbandonedWorkouts(){
        workoutRepo.fetchAll()
            .sink(receiveCompletion: { _ in }, receiveValue: {[weak self] workouts in
                guard let self else { return }
                
                let abandoned = workouts.filter { $0.name == nil || $0.name == ""   }
                
                for draft in abandoned{
                    if let id = draft.id?.uuidString{
                        self.workoutRepo.delete(by: id)
                            .sink(receiveCompletion: { _ in }, receiveValue: {_ in })
                            .store(in: &cancellables)
                    }
                }
                
                if !abandoned.isEmpty {
                    print("🧹 SplashVM: \(abandoned.count) abandoned workout(s) cleaned up.")
                }
                
            })
            .store(in: &cancellables)
       
        
    }
    
    
    //MARK: - FirebaseSync
    private func performSync(){
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
