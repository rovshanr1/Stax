//
//  WorkoutDetailVM.swift
//  Stax
//
//  Created by Rovshan Rasulov on 23.03.26.
//

import Foundation
import Combine

final class WorkoutDetailVM {
    //MARK: - I/O Structs
    ///Input: "Orders" fromd the VC (Orders)
    struct Input{
        let viewDidLoad: PassthroughSubject<Void, Never>
    }
    
    ///Output: "Data" to VC (Data Streams)
    struct Output{
        let screenTitle: CurrentValueSubject<String, Never>
        let summaryData: CurrentValueSubject<DetailSummaryItems?, Never>
    }
    
    //MARK: - Properties
    let input: Input
    let output: Output
    
    //MARK: - Dependencies
    private let workoutID: String
    private let workoutRepo: WorkoutRepositoryInterface
    private var cancellables: Set<AnyCancellable> = []
    
    init(workoutID: String, workoutRepo: WorkoutRepositoryInterface) {
        self.workoutID = workoutID
        self.workoutRepo = workoutRepo
        
        self.input = .init(viewDidLoad: .init())
      
        self.output = .init(screenTitle: .init(""),
                            summaryData: .init(nil)
        )
        
        transform()
        
    }
    
    
    private func transform(){
        input.viewDidLoad
            .sink { [weak self] in
                guard let self else { return }
                self.getWorkoutDetails()
            }
            .store(in: &cancellables)
    }
    
    
    private func getWorkoutDetails(){
        self.workoutRepo.fetchWorkouts()
        
        if let selectedWorkout = self.workoutRepo.getWorkout(by: self.workoutID) {
            
            let volumeString = "\(selectedWorkout.volume) kg"
            
            let summaryItem = DetailSummaryItems(
                workoutName: selectedWorkout.name,
                durationString: selectedWorkout.duration.formatDuration(),
                volumeString: volumeString,
                setsLabel: "\(selectedWorkout.sets)",
                caloriesBurnedString: "\(selectedWorkout.caloriesBurned)kcal")
            
            output.summaryData.send(summaryItem)
        }else{
            print("VM cant find workout with id: \(self.workoutID)")
        }
    }
    
    
}
