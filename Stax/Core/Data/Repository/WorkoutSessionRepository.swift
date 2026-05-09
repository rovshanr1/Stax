//
//  WorkoutSessionRepository.swift
//  Stax
//
//  Created by Rovshan Rasulov on 05.05.26.
//

import Foundation
import Combine

protocol SessionServiceProtocol{
    var exercisesPublisher: AnyPublisher<[WorkoutExerciseDomainModel], Never> { get }
    var sessionStatsPublisher: AnyPublisher<(volume: Double, sets: Int), Never> { get }
    
    func setupSession(workoutID: String?) -> (id: String, initialDuration: Double)
    func cancelWorkoutSession()
    func finishWorkout(duration: Double)
    
    func addExercise(exerciseID: String)
    func deleteExercise(workoutExerciseID: String)
    func replaceExercise(workoutExerciseID: String, with newExerciseID: String)
    func updateExerciseNote(workoutExerciseID: String, note: String)
    
    func addNewSet(to workoutExerciseID: String)
    func updateSet(setID: String, weight: Double, reps: Int, isDone: Bool)
    func deleteSet(setID: String)
}

final class WorkoutSessionRepository: SessionServiceProtocol{
    //Subjects
    private let exercisesSubject = CurrentValueSubject<[WorkoutExerciseDomainModel], Never>([])
    private let sessionStatsSubject = CurrentValueSubject<(volume: Double, sets: Int), Never>((0, 0))
    
    //Dictionary
    private var cachedPreviousSets: [String: [WorkoutSetDomainModel]] = [:]
    
    //Publishers
    var exercisesPublisher: AnyPublisher<[WorkoutExerciseDomainModel], Never> {
        exercisesSubject.eraseToAnyPublisher()
    }
    
    var sessionStatsPublisher: AnyPublisher<(volume: Double, sets: Int), Never> {
        sessionStatsSubject.eraseToAnyPublisher()
    }
    
    //Repositorys
    private let baseExerciseRepo: DataRepository<Exercise>
    private let exerciseRepo: DataRepository<WorkoutExercise>
    private let workoutSets: DataRepository<WorkoutSet>
    private let workoutRepo: DataRepository<Workout>
    
    //State
    private var currentWorkout: Workout?
    
    private var workoutId: String?
    
    //Combine
    private var cancellables: Set<AnyCancellable> = []
    
    init(baseExerciseRepo: DataRepository<Exercise>,
         exerciseRepo: DataRepository<WorkoutExercise>,
         workoutSets: DataRepository<WorkoutSet>,
         workoutRepo: DataRepository<Workout>) {
        self.baseExerciseRepo = baseExerciseRepo
        self.exerciseRepo = exerciseRepo
        self.workoutSets = workoutSets
        self.workoutRepo = workoutRepo
    }
    
    func setupSession(workoutID: String?) -> (id: String, initialDuration: Double) {
        if let id = workoutID, let existingWorkout = workoutRepo.fetch(by: id) {
            self.currentWorkout = existingWorkout
            
            let saveDuration = existingWorkout.duration
            return (id, saveDuration)
        }
        
        let newWorkout = workoutRepo.create()
        newWorkout.id = UUID()
        newWorkout.date = Date()
        
        self.currentWorkout = newWorkout
        
        self.notifyUI()
        
        return (newWorkout.id?.uuidString ?? "" , 0)
    }
    
    func cancelWorkoutSession() {
        
    }
    
    func finishWorkout(duration: Double) {
        
    }
    
    func addExercise(exerciseID: String) {
        guard let currentWorkout = self.currentWorkout else { return }
        
        guard let baseExercise = baseExerciseRepo.fetch(by: exerciseID) else {
            print("Error: ID not found")
            return
        }
        
        let newWorkoutExercise = exerciseRepo.create()
        newWorkoutExercise.id = UUID()
        newWorkoutExercise.exercise = baseExercise
        newWorkoutExercise.workout = currentWorkout
        
        let currentCount = currentWorkout.workoutExercises?.count ?? 0
        newWorkoutExercise.orderIndex = Int16(currentCount)
        
        let initialSet = workoutSets.create()
        initialSet.id = UUID()
        initialSet.orderIndex = 0
        initialSet.isCompleted = false
        initialSet.weight = 0
        initialSet.reps = 0
        initialSet.workoutExercise = newWorkoutExercise
        
        if let exerciseID = baseExercise.id?.uuidString,
           cachedPreviousSets[exerciseID] == nil {
            if let pastSession = exerciseRepo.fetchPreviousSession(for: baseExercise, currentWorkout: currentWorkout){
                let sortedPastSets = (pastSession.workoutSets as? Set<WorkoutSet> ?? [])
                    .sorted { $0.orderIndex < $1.orderIndex }
                
                let mappedPastSets: [WorkoutSetDomainModel] = sortedPastSets.map { cdSet in
                    return WorkoutSetDomainModel(
                        id: cdSet.id?.uuidString ?? UUID().uuidString,
                        isCompleted: cdSet.isCompleted,
                        orderIndex: cdSet.orderIndex,
                        previous: "-",
                        reps: cdSet.reps,
                        restTime: cdSet.restTime,
                        weight: cdSet.weight,
                        previousWeight: nil,
                        previousReps: nil
                    )
                }
                
                cachedPreviousSets[exerciseID] = mappedPastSets
            }
        }
        
        exerciseRepo.save()
            .sink(receiveCompletion: { completion in
                if case .failure(let failure) = completion {
                    print("Error: \(failure.localizedDescription)")
                }
            }, receiveValue: { [weak self] _ in
                self?.notifyUI()
            })
            .store(in: &cancellables)
    }
    
    func deleteExercise(workoutExerciseID: String) {
        exerciseRepo.delete(by: workoutExerciseID)
            .sink { completion in
                if case .failure(let failure) = completion {
                    print("Exercise delete error: \(failure.localizedDescription)")
                }
            } receiveValue: { [weak self] _ in
                self?.reindexExercise()
            }
            .store(in: &cancellables)
        
    }
    
    func replaceExercise(workoutExerciseID: String, with newExerciseID: String) {
        guard let workoutExercise = exerciseRepo.fetch(by: workoutExerciseID) else { return }
        
        guard let newBaseExercise = baseExerciseRepo.fetch(by: newExerciseID) else { return }
        
        workoutExercise.exercise = newBaseExercise
        
        //Replecing set stats
        if cachedPreviousSets[newExerciseID] == nil, let currentWorkout = self.currentWorkout {
            if let pastSession = exerciseRepo.fetchPreviousSession(for: newBaseExercise, currentWorkout: currentWorkout){
                let sortedPastSets = (pastSession.workoutSets as? Set<WorkoutSet> ?? [])
                    .sorted { $0.orderIndex < $1.orderIndex }
                
                let mappedPastSets: [WorkoutSetDomainModel] = sortedPastSets.map { cdSet in
                 return WorkoutSetDomainModel(
                    id: cdSet.id?.uuidString ?? UUID().uuidString,
                    isCompleted: cdSet.isCompleted,
                    orderIndex: cdSet.orderIndex,
                    previous: "-",
                    reps: cdSet.reps,
                    restTime: cdSet.restTime,
                    weight: cdSet.weight,
                    previousWeight: nil,
                    previousReps: nil
                 )
                    
                }
                cachedPreviousSets[newExerciseID] = mappedPastSets
            }
        }
        
        exerciseRepo.save()
            .sink { completion in
                if case .failure(let failure) = completion {
                    print("Error replacing exercise: \(failure.localizedDescription)")
                }
            } receiveValue: { [weak self] _ in
                self?.notifyUI()
            }
            .store(in: &cancellables)
    }
    
    func updateExerciseNote(workoutExerciseID: String, note: String) {
        guard let exercise = exerciseRepo.fetch(by: workoutExerciseID) else { return }
        
        exercise.note = note
        
        exerciseRepo.save()
            .sink { completion in
                if case .failure(let failure) = completion {
                    print("Note update error: \(failure.localizedDescription)")
                }
                
            } receiveValue: { [weak self] _ in
                self?.notifyUI()
            }
            .store(in: &cancellables)
        
    }
    
    
    func addNewSet(to workoutExerciseID: String) {
        guard let currentExercise = exerciseRepo.fetch(by: workoutExerciseID) else { return }
        
        let newSet = workoutSets.create()
        newSet.id = UUID()
        newSet.isCompleted = false
        newSet.weight = 0
        newSet.reps = 0
        newSet.workoutExercise = currentExercise
        
        let currentSetsCount = currentExercise.workoutSets?.count ?? 0
        newSet.orderIndex = Int16(currentSetsCount)
        
        workoutSets.save()
            .sink { completion in
                if case .failure(let failure) = completion {
                    print("Error saving new set: \(failure.localizedDescription)")
                }
            } receiveValue: { [weak self] _ in
                self?.notifyUI()
            }
            .store(in: &cancellables)

    }
    
    func updateSet(setID: String, weight: Double, reps: Int, isDone: Bool) {
        guard let setToUpdate = workoutSets.fetch(by: setID) else { return }
        
        setToUpdate.weight = weight
        setToUpdate.reps = Int16(reps)
        setToUpdate.isCompleted = isDone
        
        workoutSets.save()
            .sink { completion in
                if case .failure(let failure) = completion {
                    print("Error saving new set: \(failure.localizedDescription)")
                }
            } receiveValue: { [weak self] _ in
                self?.notifyUI()
            }
            .store(in: &cancellables)
    }
    
    func deleteSet(setID: String) {
        guard let setToDelete = workoutSets.fetch(by: setID),
              let parentExercise = setToDelete.workoutExercise
        else { return }
        
        workoutSets.delete(by: setID)
            .sink { completion in
                if case .failure(let failure) = completion {
                    print("Error deleting set: \(failure.localizedDescription)")
                }
            } receiveValue: { [weak self] _ in
                self?.reindexSets(for: parentExercise)
            }
            .store(in: &cancellables)

    }
    
    //MARK: - NotifyUI
    private func notifyUI(){
        guard let id = currentWorkout?.id?.uuidString,
              let freshWorkout = workoutRepo.fetch(by: id) else { return }
        
        let coreDataExercise = (freshWorkout.workoutExercises as? Set<WorkoutExercise> ?? [])
            .sorted {$0.orderIndex < $1.orderIndex}
        
        var totalVolume: Double = 0
        var totalSets: Int = 0
        
        let domainWorkoutExercises: [WorkoutExerciseDomainModel] = coreDataExercise.map { cdExercise in
            
            var previousSetsSorted: [WorkoutSetDomainModel] = []
            if let baseDefID = cdExercise.exercise?.id?.uuidString {
                previousSetsSorted = cachedPreviousSets[baseDefID] ?? []
            }
            
            let coreDataSets = (cdExercise.workoutSets as? Set<WorkoutSet> ?? [])
                .sorted { $0.orderIndex < $1.orderIndex }
            
            let domainSets: [WorkoutSetDomainModel] = coreDataSets.enumerated().map { index, cdSet in
                if cdSet.isCompleted {
                    totalVolume += (cdSet.weight * Double(cdSet.reps))
                    totalSets += 1
                }
                
                var previousString = "-"
                
                var fetchedPrevWeight: Double? = nil
                var fetchedPrevReps: Int16? = nil
                
                if index < previousSetsSorted.count {
                    let pastSet = previousSetsSorted[index]
                    
                    fetchedPrevWeight = pastSet.weight
                    fetchedPrevReps = pastSet.reps
                    
                    let weightStr = floor(pastSet.weight) == pastSet.weight ? "\(Int(pastSet.weight))" : String(format: "%.1f", pastSet.weight)
                    previousString = "\(weightStr)kg x \(pastSet.reps)"
                }
                
                return WorkoutSetDomainModel(
                    id: cdSet.id?.uuidString ?? UUID().uuidString,
                    isCompleted: cdSet.isCompleted,
                    orderIndex: cdSet.orderIndex,
                    previous: previousString,
                    reps: cdSet.reps,
                    restTime: cdSet.restTime,
                    weight: cdSet.weight,
                    previousWeight: fetchedPrevWeight,
                    previousReps: fetchedPrevReps
                    
                )
                
            }
            
            var baseExerciseDomain: ExerciseDomainModel?
            if let cdDef = cdExercise.exercise{
                let muscleGroupEnum = MuscleGroup(rawValue: cdDef.targetMuscle ?? "")
                
                baseExerciseDomain = ExerciseDomainModel(id: cdDef.id?.uuidString ?? UUID().uuidString,
                                                         name: cdDef.name ?? "Unknown Name",
                                                         targetMuscleGroups: muscleGroupEnum ,
                                                         videoURL: cdDef.videoURL,
                                                         exerciseImage: cdDef.exerciseImage
                )
            }
            
            return WorkoutExerciseDomainModel(
                id: cdExercise.id?.uuidString ?? UUID().uuidString,
                notes: cdExercise.note,
                orderIndex: cdExercise.orderIndex,
                exercise: baseExerciseDomain,
                workoutSets: domainSets
            )
            
        }
        
        self.exercisesSubject.send(domainWorkoutExercises)
        self.sessionStatsSubject.send((volume: totalVolume, sets: totalSets))
    }
    
    
    
    //MARK: - Reindexing
    private func reindexExercise(){
        guard let currentWorkout = self.currentWorkout else { return }
        
        let remainingExercises = (currentWorkout.workoutExercises as? Set<WorkoutExercise> ?? [])
            .sorted { $0.orderIndex < $1.orderIndex }
        
        for (index, exercise) in remainingExercises.enumerated() {
            exercise.orderIndex = Int16(index)
        }
        
        exerciseRepo.save()
            .sink { comletion in
                if case .failure(let error) = comletion {
                    print("Reindexing failed: \(error)")
                }
            } receiveValue: { [weak self] _ in
                self?.notifyUI()
            }
            .store(in: &cancellables)
    }
    
    private func reindexSets(for workoutExercise: WorkoutExercise){
        let remainingSets = (workoutExercise.workoutSets as? Set<WorkoutSet> ?? [])
            .sorted { $0.orderIndex < $1.orderIndex }
        
        for (index, set) in remainingSets.enumerated() {
            set.orderIndex = Int16(index)
        }
        
        workoutSets.save()
            .sink { comletion in
                if case .failure(let error) = comletion {
                    print("Reindexing failed: \(error)")
                }
            } receiveValue: { [weak self] _ in
                self?.notifyUI()
            }
            .store(in: &cancellables)
            
    }
}
