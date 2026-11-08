//
//  MockWorkoutRepository.swift
//  StaxTests
//
//  Created by Rovshan Rasulov on 11.06.26.
//

import Foundation
@testable import Stax
import Combine

final class MockWorkoutRepository: WorkoutRepositoryProtocol {

    let workoutPublisher: CurrentValueSubject<[WorkoutDomainModel]?, Never>

    var isFetchWorkoutCalled = false
    var capturedDeletedWorkoutID: String?
    var stubbedWorkoutToReturn: WorkoutDomainModel?
    var stubbedWorkoutDetails: WorkoutDomainModel?
    var stubbedFinalizedWorkout: WorkoutDomainModel?

    init(initialWorkouts: [WorkoutDomainModel] = []) {
        self.workoutPublisher = CurrentValueSubject(initialWorkouts)
    }

    func fetchWorkouts() {
        isFetchWorkoutCalled = true
    }

    func deleteWorkout(by id: String) {
        capturedDeletedWorkoutID = id
    }

    func getWorkout(by id: String) -> WorkoutDomainModel? {
        stubbedWorkoutToReturn
    }

    func fetchWorkoutDetails(by id: String) -> WorkoutDomainModel? {
        stubbedWorkoutDetails
    }

    func finalizeWorkout(
        id: String,
        title: String,
        description: String,
        stats: WorkoutStats
    ) async throws -> WorkoutDomainModel {
        guard let workout = stubbedFinalizedWorkout else {
            throw MockError.missingStub
        }

        return workout
    }
}

private enum MockError: Error {
    case missingStub
}

