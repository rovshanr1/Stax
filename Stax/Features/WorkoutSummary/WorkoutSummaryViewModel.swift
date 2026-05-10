//
//  WorkoutSummaryViewModel.swift
//  Stax
//
//  Created by Rovshan Rasulov on 31.01.26.
//

import Foundation
import Combine


final class WorkoutSummaryViewModel{
    //MARK: - I/O Structs
    ///Input: "Orders" fromd the VC (Orders)
    struct Input{
        let viewDidLoad: PassthroughSubject<Void, Never>
        let updateTitle: PassthroughSubject<String, Never>
        let updateDescription: PassthroughSubject<String, Never>
        let saveWorkout: PassthroughSubject<Void, Never>
        let toggleHealthKitSync: PassthroughSubject<Bool, Never>
        let discardWorkout: PassthroughSubject<Void, Never>
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
    public private(set) var workout: Workout?
    private let workoutRepository: DataRepository<Workout>
    
    //Stats
    private let stats: WorkoutStats
    private let workoutID: String
    
    //Preferance Service
    private var preferencesService: AppPreferencesServiceInterface
    private let healthKitService: HealthKitServiceInterface?
    private let syncService: FirebaseSyncServiceInterface
    private let appDIContainer: AppDIContainer
    
    private var cancellables: Set<AnyCancellable> = []
    
    let emojis = ["🔥", "💪", "🏋️‍♂️", "🏃‍♂️", "🦍", "⚡️"]
    
    init(workoutID: String,
         workoutRepository: DataRepository<Workout>,
         stats: WorkoutStats,
         preferancesService: AppPreferencesServiceInterface = AppPreferencesService(),
         healthKitService: HealthKitServiceInterface = HealthKitService(),
         syncService: FirebaseSyncServiceInterface = FirebaseSyncService(),
         appDIContainer: AppDIContainer
    ){
        self.workoutID = workoutID
        self.workoutRepository = workoutRepository
        self.appDIContainer = appDIContainer
        self.stats = stats
        self.preferencesService = preferancesService
        self.healthKitService = healthKitService
        self.syncService = syncService
        
        self.workout = workoutRepository.fetch(by: workoutID)
        
        self.input = Input(
            viewDidLoad: .init(),
            updateTitle: .init(),
            updateDescription: .init(),
            saveWorkout: .init(),
            toggleHealthKitSync: .init(),
            discardWorkout: .init()
        )
        
        self.output = Output(
            defaultTitle: .init(""),
            finished: .init(),
            workoutStats: .init(),
            isHealthKitSyncEnabled: .init(preferencesService.isHealthKitSyncEnabled)
        )
        
        transform()
    }
    
    private func transform(){
        input.viewDidLoad
            .sink { [weak self] in
                self?.setupInitialData()
            }
            .store(in: &cancellables)
        
        input.saveWorkout
            .flatMap{ [weak self] _ -> AnyPublisher<Void, Error> in
                guard let self, let workout = self.workout else {return Empty().eraseToAnyPublisher()}
                
                if (workout.name == nil || workout.name?.isEmpty == true) {
                    workout.name = self.output.defaultTitle.value
                }
                
                if let calculatedCalories = self.stats.caloriesBurned {
                    workout.calories = Int16(calculatedCalories)
                }
                
                workout.sets = Int16(self.stats.totalSets)
                workout.volume = self.stats.volume
                workout.duration = self.stats.duration
                
                
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
        
        input.discardWorkout
            .sink { [weak self] _ in
                guard let self, let workoutToDelete = self.workout, let id = workoutToDelete.id?.uuidString else { return }
                
                self.workoutRepository.delete(by: id)
                    .sink { _ in } receiveValue: { _ in }
                    .store(in: &cancellables)
                
            }
            .store(in: &cancellables)
    }
    
    
    //Helper Methods
    private func setupInitialData(){
        guard let workout = self.workout else { return }
        
        let randomEmoji = emojis.randomElement() ?? "💪"
        
        let dateToUse = workout.date ?? Date()
        let defaultName = "\(dateToUse.dayName()) Workout\(randomEmoji)"
        let currentTitle = (workout.name?.isEmpty == false) ? workout.name! : defaultName
        
        self.output.defaultTitle.send(currentTitle)
        
        let presentation = WorkoutSummaryPresentation(duration: stats.duration.formatDuration(),
                                                      volume: stats.volume.formatWeight(),
                                                      sets: stats.totalSets,
                                                      date: dateToUse
        )
        
        self.output.workoutStats.send(presentation)
    }
    
    private func updateWorkoutName(_ newTitle: String){
        guard let workout = self.workout else { return }
        
        let cleanTitle = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleanTitle.isEmpty {
            workout.name = nil
        }else{
            workout.name = cleanTitle
        }
    }
    
    private func updateWorkoutDescription(_ newDescription: String){
        guard let workout = self.workout else { return }
        
        let cleanDescription = newDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleanDescription.isEmpty{
            workout.workoutDescription = ""
        }else{
            workout.workoutDescription = cleanDescription
        }
    }
    
    private func updateHelathKit(){
        guard let workout = self.workout else { return }
        
        if self.preferencesService.isHealthKitSyncEnabled {
            self.healthKitService?.saveWorkout(
                duration: self.stats.duration,
                volume: self.stats.volume,
                sets: self.stats.totalSets,
                calories: Double(workout.calories),
                date: workout.date ?? Date()) { success, error in
                    DispatchQueue.main.async {
                        self.output.finished.send()
                    }
                }}else{
                    self.output.finished.send()
                }
    }
    
    private func syncToFirebase(){
        guard let workout = self.workout else { return }
        
        let domainModel = workout.toDomain()
        
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
