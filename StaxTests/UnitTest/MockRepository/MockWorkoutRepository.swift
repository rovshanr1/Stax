//
//  MockWorkoutRepository.swift
//  StaxTests
//
//  Created by Rovshan Rasulov on 11.06.26.
//

import Foundation
@testable import Stax
import Combine

final class MockWorkoutRepository: WorkoutRepositoryProtocol{
    let workoutPublisher: CurrentValueSubject<[Stax.WorkoutDomainModel], Never>
    
    var isFetchWorkoutCalled = false
    var capturedDeletedWorkoutID: String?
    
    var stubbedWorkoutToReturn: Stax.WorkoutDomainModel?
    
    init(initialWorkouts: [Stax.WorkoutDomainModel] = []) {
        self.workoutPublisher = CurrentValueSubject(initialWorkouts)
    }
    
    
    func fetchWorkouts() {
        isFetchWorkoutCalled = true
    }
    
    func deleteWorkout(by id: String) {
        capturedDeletedWorkoutID = id
    }
    
    func getWorkout(by id: String) -> Stax.WorkoutDomainModel? {
        return stubbedWorkoutToReturn
    }
    
    
}
