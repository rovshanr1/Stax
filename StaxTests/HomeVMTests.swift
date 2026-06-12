//
//  HomeVMTests.swift
//  StaxTests
//
//  Created by Rovshan Rasulov on 12.06.26.
//

import XCTest
@testable import Stax
import Combine

final class HomeVMTests: XCTestCase {
    var sut: HomeVM!
    var mockWorkoutRepository: MockWorkoutRepository!
    var mockWorkoutShareService: MockWorkoutShareService!
    var mockFirebaseService: MockFirebaseSyncService!
    
    override func setUp() {
        super.setUp()
        mockWorkoutRepository = MockWorkoutRepository()
        mockWorkoutShareService = MockWorkoutShareService()
        mockFirebaseService = MockFirebaseSyncService()
        
        sut = HomeVM(workoutRepo: mockWorkoutRepository,
                     shareService: mockWorkoutShareService,
                     synService: mockFirebaseService)
    }
    
    override func tearDown() {
        sut = nil
        mockWorkoutRepository = nil
        mockWorkoutShareService = nil
        mockFirebaseService = nil
        super.tearDown()
    }
    
    func test_deleteWorkout_invokesRepositoryWithCorrectID(){
        let id: String = "ABC-123"

        sut.input.deleteWorkout.send(id)
        
        XCTAssertEqual(mockWorkoutRepository.capturedDeletedWorkoutID, id, "Repository should be called with the correct workout ID")
    }
}
