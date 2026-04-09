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
    //MARK: - I/O Structs
    ///Input: "Orders" fromd the VC (Orders)
    struct Input{
        let viewDidLoad: PassthroughSubject<Void, Never>
        let updateTitle: PassthroughSubject<String, Never>
        let updateDescription: PassthroughSubject<String, Never>
        let saveWorkout: PassthroughSubject<Void, Never>
        let toggleHealthKitSync: PassthroughSubject<Bool, Never>
    }
    
    ///Output: "Data" to VC (Data Streams)
    struct Output{
        let defaultTitle: CurrentValueSubject<String, Never>
        let finished: PassthroughSubject<Void, Never>
        let workoutStats: PassthroughSubject<WorkoutSummaryPresentation, Never>
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
    private var preferencesService: AppPreferencesServiceInterface
    private let healthKitService: HealthKitServiceInterface?
    private let syncService: FirebaseSyncServiceInterface
    
    private var cancellables: Set<AnyCancellable> = []
    
    let emojis = ["🔥", "💪", "🏋️‍♂️", "🏃‍♂️", "🦍", "⚡️"]
    
    init(workout: Workout,
         workoutRepository: DataRepository<Workout>,
         stats: WorkoutStats,
         preferancesService: AppPreferencesServiceInterface = AppPreferencesService(),
         healthKitService: HealthKitServiceInterface = HealthKitService(),
         syncService: FirebaseSyncServiceInterface = FirebaseSyncService()
         
    ){
        self.workout = workout
        self.workoutRepository = workoutRepository
        self.stats = stats
        self.preferencesService = preferancesService
        self.healthKitService = healthKitService
        self.syncService = syncService
        
        self.input = Input(
            viewDidLoad: .init(),
            updateTitle: .init(),
            updateDescription: .init(),
            saveWorkout: .init(),
            toggleHealthKitSync: .init())
        
        self.output = Output(
            defaultTitle: .init(""),
            finished: .init(),
            workoutStats: .init(),
            isHealthKitSyncEnabled: .init(preferencesService.isHealthKitSyncEnabled))
        
        self.transform()
    }
    
    private func transform(){
        input.viewDidLoad
            .sink { [weak self] in
                self?.setupInitialData()
            }
            .store(in: &cancellables)
        
        input.saveWorkout
            .flatMap{ [weak self] _ -> AnyPublisher<Void, Error> in
                guard let self else {return Empty().eraseToAnyPublisher()}
                if (self.workout.name == nil || self.workout.name?.isEmpty == true) {
                    self.workout.name = self.output.defaultTitle.value
                }
                return self.workoutRepository.save()
            }
            .sink(receiveCompletion: { completion in
                if case .failure(let failure) = completion {
                    print(failure)
                }
            }, receiveValue: { [weak self] _ in
                guard let self else { return }
                
                self.syncToFirebase()
                self.updateHelathKit()
                
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
                
                if isEnabled {
                    self.healthKitService?.requestAuthorization { [weak self] success, error in
                        guard let self else { return }
                        if success {
                            self.preferencesService.isHealthKitSyncEnabled = true
                            self.output.isHealthKitSyncEnabled.send(true)
                        }else{
                            print("HealhKit Authorization Failed: \(error?.localizedDescription ?? "Unknown Error")")
                            self.preferencesService.isHealthKitSyncEnabled = false
                            self.output.isHealthKitSyncEnabled.send(false)
                        }
                    }
                }else{
                    self.preferencesService.isHealthKitSyncEnabled = false
                    self.output.isHealthKitSyncEnabled.send(false)
                }
                
            }
            .store(in: &cancellables)
    }
    
    
    //Helper Methods
    private func setupInitialData(){
        let randomEmoji = emojis.randomElement() ?? "💪"

        let dateToUse = workout.date ?? Date()
        let defaultName = "\(dateToUse.dayName()) Workout\(randomEmoji)"
        let currentTitle = (workout.name?.isEmpty == false) ? workout.name! : defaultName
        
        self.output.defaultTitle.send(currentTitle)
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        let durationString = formatter.string(from: stats.duration) ?? "0s"
        
        let presentation = WorkoutSummaryPresentation(duration: durationString,
                                                      volume: stats.volume,
                                                      sets: stats.totalSets,
                                                      date: dateToUse
        )
        
        self.output.workoutStats.send(presentation)
    }
    
    private func updateWorkoutName(_ newTitle: String){
        let cleanTitle = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleanTitle.isEmpty {
            workout.name = nil
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
    
    private func updateHelathKit(){
        if self.preferencesService.isHealthKitSyncEnabled {
            self.healthKitService?.saveWorkout(
                duration: self.stats.duration,
                volume: self.stats.volume,
                sets: self.stats.totalSets,
                calories: Double(self.workout.calories),
                date: self.workout.date ?? Date()) { success, error in
                    DispatchQueue.main.async {
                        self.output.finished.send()
                    }
                }}else{
                    self.output.finished.send()
                }
    }
    
    private func syncToFirebase(){
        let domainModel = self.workout.toDomain()
        
        self.syncService.syncWorkoutToCloud(workout: domainModel) { result in
            switch result{
            case .success:
                print("Workout save to Firebase")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
