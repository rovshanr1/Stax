//
//  MockFirebaseSyncService.swift
//  StaxTests
//
//  Created by Rovshan Rasulov on 12.06.26.
//

import Foundation
@testable import Stax
import Combine


final class MockFirebaseSyncService: FirebaseSyncServiceInterface {

    func syncWorkoutToCloud(workout: WorkoutDomainModel) async throws {}

    func deleteWorkoutFromCloud(workoutId: String) async throws {}

    func fetchInitialWorkoutsFromCloud() async throws -> [WorkoutDomainModel] {
        []
    }

    func deleteDataBaseFromFirebase() async throws {}

    func syncWorkoutToCloud(
        workout: WorkoutDomainModel,
        completion: @escaping (Result<Void, any Error>) -> Void
    ) {
        completion(.success(()))
    }

    func deleteWorkoutFromCloud(
        workoutId: String,
        completion: @escaping (Result<Void, any Error>) -> Void
    ) {
        completion(.success(()))
    }

    func fetchInitialWorkoutsFromCloud(
        completion: @escaping (Result<[WorkoutDomainModel], any Error>) -> Void
    ) {
        completion(.success([]))
    }
}
