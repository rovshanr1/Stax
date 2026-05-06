//
//  WorkoutSessionVM.swift
//  Stax
//
//  Created by Rovshan Rasulov on 05.12.25.
//
import Foundation
import Combine


final class WorkoutSessionViewModel{
    //MARK: - I/O Structs
    ///Input: "Orders" fromd the VC (Orders)
    struct Input{
        let viewDidLoad: PassthroughSubject<Void, Never>
        let viewDidAppear: PassthroughSubject<Void, Never>
        let didTapFinish: PassthroughSubject<Void, Never>
        let didTapCancel: PassthroughSubject<Void, Never>
        let addExercise: PassthroughSubject<ExerciseDomainModel, Never>
        let addSet: PassthroughSubject<WorkoutExerciseDomainModel, Never>
        let updateExerciseNote: PassthroughSubject<(String, String), Never>
        let replaceExercise: PassthroughSubject<(WorkoutExerciseDomainModel, ExerciseDomainModel), Never>
        let deleteExercise: PassthroughSubject<WorkoutExerciseDomainModel, Never>
        let updateSet: PassthroughSubject<(String, Double, Int, Bool), Never>
        let deleteSet: PassthroughSubject<String, Never>
    }
    
    ///Output: "Data" to VC (Data Streams)
    struct Output{
        let timerSubject: CurrentValueSubject<String, Never>
        let finishWorkoutEvent: PassthroughSubject<Void, Never>
        let cancelWorkoutEvent: PassthroughSubject<Void, Never>
        let exercises: CurrentValueSubject<[WorkoutExerciseDomainModel], Never>
        let sessionStats: CurrentValueSubject<(volume: Double, sets: Int), Never>
    }
    
    //MARK: - Properties
    let input: Input
    let output: Output
    
    
    //Services
    public private(set) var timerService: WorkoutTimerServiceProtocol
    private let sessionService: SessionServiceProtocol
    private let workoutRepository: WorkoutRepositoryProtocol
    
    //State

    public private(set) var currentStats: (volume: Double, sets: Int) = (0, 0)
    
    private let workoutId: String?
    
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    private var secondsElapsed: Int = 0
    
    
    
    //MARK: - Initializer
    init( sessionService: SessionServiceProtocol,
          workoutRepository: WorkoutRepositoryProtocol,
         timerService: WorkoutTimerServiceProtocol = WorkoutTimerService(),
         workoutId: String? = nil
    ){
        self.sessionService = sessionService
        self.workoutRepository = workoutRepository
        self.timerService = timerService
        self.workoutId = workoutId
        
        self.input = .init(viewDidLoad: .init(),
                           viewDidAppear: .init(),
                           didTapFinish: .init(),
                           didTapCancel: .init(),
                           addExercise: .init(),
                           addSet: .init(),
                           updateExerciseNote: .init(),
                           replaceExercise: .init(),
                           deleteExercise: .init(),
                           updateSet: .init(),
                           deleteSet: .init()
        )
        
        self.output = .init(timerSubject: .init("0s"),
                            finishWorkoutEvent: .init(),
                            cancelWorkoutEvent: .init(),
                            exercises: .init([]),
                            sessionStats: .init((volume: 0.0, sets: 0))
                            
        )
        
        
        transform()
    }
    
    
    //MARK: - Transform method
    private func transform() {
        timerService.timerPublisher
            .sink { [weak self] time in
                self?.output.timerSubject.send(time)
            }
            .store(in: &cancellables)
        
        input.viewDidLoad
            .sink { [weak self] in
                guard let self else { return }
                
                let sessionData = self.sessionService.setupSession(workoutID: self.workoutId)
                
                self.timerService.setInitialTime(sessionData.initialDuration)
                
            }
            .store(in: &cancellables)
        
        input.viewDidAppear
            .sink { [weak self] in
                guard let self else {return}
                
                self.timerService.start()
            }
            .store(in: &cancellables)
        
        input.didTapFinish
            .sink { [weak self] _ in
                guard let self else {return}
                
                self.timerService.stop()
                
                let finalDuration = Double(self.timerService.seconsElapsed)
                let estimatedCalories = (finalDuration / 60.0) * 6.0
                
            
                self.output.finishWorkoutEvent.send()
            }
            .store(in: &cancellables)
        
        input.didTapCancel
            .sink { [weak self] in
                guard let self else {return}
                
                self.output.cancelWorkoutEvent.send()
            }
            .store(in: &cancellables)
        
        
        setupExerciseBindings()
    }
  
    private func setupExerciseBindings(){
        input.addExercise
            .sink { [weak self] exercise in
                
            }
            .store(in: &cancellables)
        
        input.updateExerciseNote
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] (objectId, noteText) in
                
                
            }
            .store(in: &cancellables)
        
        input.replaceExercise
            .sink(receiveValue: {[weak self] (existingExercise, newExerciseDefinition) in
            
            })
            .store(in: &cancellables)
        
        input.deleteExercise
            .sink (receiveValue: { [weak self] exercise in
                
            })
            .store(in: &cancellables)
        
        input.addSet
            .sink(receiveValue: { [weak self] exercise in
                
            })
            .store(in: &cancellables)
        
        input.updateSet
            .sink(receiveValue: { [weak self] setID, weight, reps, isDone in
              
            })
            .store(in: &cancellables)
                
        input.deleteSet
            .sink(receiveValue: { [weak self] setID in
                
            })
            .store(in: &cancellables)
    }
    
    //MARK: - Logic Helpers

}

//MARK: - Helper Methods
extension WorkoutSessionViewModel {
//    private func reindexExercise(){
//        guard let exercises = frc?.fetchedObjects else {return}
//        
//        for(index, exercise) in exercises.enumerated() {
//            exercise.orderIndex = Int16(index)
//        }
//    }
//    
//    private func reindexSets(for exercise: WorkoutExercise){
//        guard let sets = exercise.workoutSets as? Set<WorkoutSet> else {return}
//        
//        let sortedSets = sets.filter { !$0.isDeleted }.sorted {$0.orderIndex < $1.orderIndex }
//        
//        for (index, set) in sortedSets.enumerated(){
//            set.orderIndex = Int16(index)
//        }
//    }
//    
//    private func refreshExercisesFromFRC(){
//        if let exercises = self.frc?.fetchedObjects {
//            self.output.exercises.send(exercises)
//        }
//    }
}


//MARK: - History Logic
//extension WorkoutSessionViewModel {
//    private func getPreviousHistory(for exerciseDef: Exercise, setIndex: Int) -> String{
//        guard let currentWorkout = currentWorkout else { return "-" }
//        
//        guard let lastSessionExercise = exerciseRepo.fetchPreviousSession(for: exerciseDef, currentWorkout: currentWorkout),
//              let lastSets = lastSessionExercise.workoutSets as? Set<WorkoutSet> else{
//            return "-"
//        }
//        
//        let sortedLastSets = lastSets.sorted { $0.orderIndex < $1.orderIndex }
//        
//        if setIndex < sortedLastSets.count {
//            let pastSet = sortedLastSets[setIndex]
//            
//            let weightString = floor(pastSet.weight) == pastSet.weight ? "\(Int(pastSet.weight))" : String(format: "%.1f", pastSet.weight)
//            return "\(weightString)kg x \(pastSet.reps)"
//        }
//        
//        return "-"
//    }
//}
