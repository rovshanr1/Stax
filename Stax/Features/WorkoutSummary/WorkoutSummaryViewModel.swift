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
        let updateDescription: PassthroughSubject<String, Never>
        let saveWorkout: PassthroughSubject<Void, Never>
        let toggleHealthKitSync: PassthroughSubject<Bool, Never>
    }
    
    struct Output{
        let defaultTitle: CurrentValueSubject<String, Never>
        let finished: PassthroughSubject<Void, Never>
        let workoutStats: CurrentValueSubject<WorkoutSummaryPresentation, Never>
        let isHealthKitSyncEnabled: CurrentValueSubject<Bool, Never>
    }
    //MARK: - Properties
    let input: Input
    let output: Output
    
    //Repositorys
    public private(set) var workout: Workout
    private let workoutRepository: DataRepository<Workout>
    
    //Stats
    private let stats: WorkoutStats
    
    //Preferance Service
    private var preferacesService: AppPreferencesServiceInterface
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(workout: Workout,
         workoutRepository: DataRepository<Workout>,
         stats: WorkoutStats, preferancesService: AppPreferencesServiceInterface = AppPreferencesService()
    ){
        self.workout = workout
        self.workoutRepository = workoutRepository
        self.stats = stats
        self.preferacesService = preferancesService
        
        self.input = Input(
            viewDidLoad: .init(),
            updateTitle: .init(),
            updateDescription: .init(),
            saveWorkout: .init(),
            toggleHealthKitSync: .init()
        )
        
        let currentTitle = workout.name ?? "New Workout"
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        let durationString = formatter.string(from: stats.duration) ?? "0s"
        
        let presentation = WorkoutSummaryPresentation(duration: durationString,
                                        volume: stats.volume,
                                        sets: stats.totalSets,
                                        date: workout.date ?? Date()
        )
        
        self.output = Output(
            defaultTitle: .init(currentTitle),
            finished: .init(),
            workoutStats: .init(presentation),
            isHealthKitSyncEnabled: .init(preferacesService.isHealthKitSyncEnabled)
        )
        
        self.transform()
    }
    
    private func transform(){
        input.saveWorkout
            .flatMap{ [weak self] _ -> AnyPublisher<Void, Error> in
                guard let self else {return Empty().eraseToAnyPublisher()}
                
                self.workout.date = Date()
                
                return self.workoutRepository.save()
            }
            .sink(receiveCompletion: { completion in
                if case .failure(let failure) = completion {
                    print(failure)
                }
            }, receiveValue: { [weak self] _ in
                self?.output.finished.send()
            })
            .store(in: &self.cancellables)
        
        input.updateTitle
            .sink { [weak self] newTitle in
                guard let self else { return }
                self.updateWorkoutName(newTitle)
            }
            .store(in: &cancellables)
        
        input.updateDescription
            .sink { [weak self] newDescription in
                guard let self else { return }
                self.updateWorkoutDescription(newDescription)
            }
            .store(in: &cancellables)
        
        input.toggleHealthKitSync
            .sink { [weak self] isEnabled in
                guard let self else{ return }
                
                self.preferacesService.isHealthKitSyncEnabled = isEnabled
                self.output.isHealthKitSyncEnabled.send(isEnabled)
                
                print("\(preferacesService)")
            }
            .store(in: &cancellables)
    }
    
    
    private func updateWorkoutName(_ newTitle: String){
        let cleanTitle = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleanTitle.isEmpty {
            workout.name = "New Workout"
        }else{
            workout.name = cleanTitle
        }
    }
    
    private func updateWorkoutDescription(_ newDescription: String){
        let cleanDescription = newDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleanDescription.isEmpty{
            workout.workoutDescription = ""
        }else{
            workout.workoutDescription = cleanDescription
        }
    }
}
