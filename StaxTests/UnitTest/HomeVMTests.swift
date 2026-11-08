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
    
    var cancellables: Set<AnyCancellable>!
    
    var mockWorkoutDM = WorkoutDomainModel(id: "ABC-123",
                                           name: "x",
                                           duration: 0,
                                           volume: 0,
                                           workoutDescription: nil,
                                           date: Date(),
                                           caloriesBurned: 0,
                                           sets: 0,
                                           workoutExercises: [])
    
    override func setUp() {
        super.setUp()
        mockWorkoutRepository = MockWorkoutRepository()
        mockWorkoutShareService = MockWorkoutShareService()
        mockFirebaseService = MockFirebaseSyncService()
        
        cancellables = []
        
        sut = HomeVM(workoutRepo: mockWorkoutRepository,
                     shareService: mockWorkoutShareService,
                     synService: mockFirebaseService)
        
        mockWorkoutRepository.stubbedWorkoutToReturn = mockWorkoutDM
        
        
        
    }
    
    override func tearDown() {
        sut = nil
        mockWorkoutRepository = nil
        mockWorkoutShareService = nil
        mockFirebaseService = nil
        cancellables = nil
        super.tearDown()
    }
    
    func test_deleteWorkout_invokesRepositoryWithCorrectID(){
        let id: String = "ABC-123"
        
        sut.input.deleteWorkout.send(id)
        
        XCTAssertEqual(mockWorkoutRepository.capturedDeletedWorkoutID, id, "Repository should be called with the correct workout ID")
    }
    
    func test_shateWorkout_invokesShareServiceWithCorrectID(){
        let expectedID: String = "ABC-123"
        
        sut.input.shareWorkout.send(expectedID)
        
        XCTAssertEqual(mockWorkoutShareService.capturedWorkoutToShare?.id, expectedID, "Share Service was called with the wrong training!")
    }
    
    func test_shareWorkout_publishesShareTextToOutput(){
        let expectedID: String = "ABC-123"
        let expectedShareText: String = "heute habe ich seher gut Sport gemacht"
        
        mockWorkoutShareService.stubbedShareText = expectedShareText
        
        let expectation = XCTestExpectation(description: "ViewModel should publish share text to output")
        
        var capturedOutputText: String?
        
        sut.output.showShareSheet
            .sink { text in
                capturedOutputText = text
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.input.shareWorkout.send(expectedID)
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(capturedOutputText, expectedShareText, "ViewModel either threw out incorrect text or no text at all!")
        
    }
}
