//
//  WorkoutSummaryViewModel.swift
//  Stax
//
//  Created by Rovshan Rasulov on 31.01.26.
//

import Foundation
import Combine
import CoreData

final class WorkoutSummaryViewModel{
    
    struct Input{
        let viewDidLoad: PassthroughSubject<Void, Never>
        let updateTitle: PassthroughSubject<String, Never>
        let saveWorkout: PassthroughSubject<Void, Never>
    }
    
    struct Output{
        let defaultTitle: CurrentValueSubject<String, Never>
        let finished: PassthroughSubject<Void, Never>
    }
    
    let input: Input
    let output: Output
    
    private let workout: Workout
    private let workoutRepository: DataRepository<Workout>
    private var cancellables: Set<AnyCancellable> = []
    
    init(workout: Workout, workoutRepository: DataRepository<Workout>){
        self.workout = workout
        self.workoutRepository = workoutRepository
        
        self.input = Input(
            viewDidLoad: .init(),
            updateTitle: .init(),
            saveWorkout: .init()
        )
        
        let currentTitle = workout.name ?? "New Workout"
        
        self.output = Output(
            defaultTitle: .init(currentTitle),
            finished: .init()
        )
        
        self.transform()
    }
    
    private func transform(){
        input.saveWorkout
            .sink { [weak self] _ in
                guard let self else { return }
                
                self.workout.date = Date()
                
                self.workoutRepository.save()
                    .sink(receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            print("Failed to save workout: \(error)")
                        }
                    }, receiveValue: { _ in
                        self.output.finished.send()
                    })
                    .store(in: &cancellables)
            }
            .store(in: &self.cancellables)
    }
}
