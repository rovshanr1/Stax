//
//  MockFirebaseSyncService.swift
//  StaxTests
//
//  Created by Rovshan Rasulov on 12.06.26.
//

import Foundation
@testable import Stax
import Combine


final class MockFirebaseSyncService: FirebaseSyncServiceInterface{
    func syncWorkoutToCloud(workout: Stax.WorkoutDomainModel, completion: @escaping (Result<Void, any Error>) -> Void) {
        
    }
    
    func deleteWorkoutFromCloud(workoutId: String, completion: @escaping (Result<Void, any Error>) -> Void) {
        
    }
    
    func fetchInitialWorkoutsFromCloud(completion: @escaping (Result<[Stax.WorkoutDomainModel], any Error>) -> Void) {
        
    }
    
    
}
