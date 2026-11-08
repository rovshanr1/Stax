//
//  WorkoutSessionRepository.swift
//  Stax
//
//  Created by Rovshan Rasulov on 05.05.26.
//

import Foundation
import Combine
import CoreData

protocol SessionServiceProtocol{
    var currentWorkoutID: String? { get }
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
    private var isEditMode: Bool = false
    
    var currentWorkoutID: String? { return currentWorkout?.id?.uuidString }
    
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
    
    //MARK: - Session
    
    func setupSession(workoutID: String?) -> (id: String, initialDuration: Double) {
        if let id = workoutID, let existingWorkout = workoutRepo.fetch(by: id) {
            self.currentWorkout = existingWorkout
            self.isEditMode = true
            
            let saveDuration = existingWorkout.duration
            self.notifyUI()
            
            return (id, saveDuration)
        }
        
        self.isEditMode = false
        
        let newWorkout = workoutRepo.create()
        newWorkout.id = UUID()
        newWorkout.date = Date()
        
        self.currentWorkout = newWorkout
        
        self.notifyUI()
        return (newWorkout.id?.uuidString ?? "" , 0)
    }
    
    func cancelWorkoutSession() {
        guard let workout = currentWorkout,
              let workoutID = workout.id?.uuidString else { return }
        
        if isEditMode {
            resetState()
            isEditMode = false
            return
        }
        
        workoutRepo.delete(by: workoutID)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error canceling workout: \(error)")
                }
            } receiveValue: { [weak self] _ in
                self?.resetState()
            }
            .store(in: &cancellables)
    }

    
    func finishWorkout(duration: Double) {
        guard let workout = self.currentWorkout else { return }
        
        workout.duration = duration
        
        workoutRepo.save()
            .sink { completion  in
                if case .failure(let error) = completion{
                    print("Error finishing workout: \(error)")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
        
    }
    
    private func resetState(){
        currentWorkout = nil
        cachedPreviousSets.removeAll()
        exercisesSubject.send([])
        sessionStatsSubject.send((volume: 0, sets: 0))
    }
    
    //MARK: - Exercises
    func addExercise(exerciseID: String) {
        guard let currentWorkout = self.currentWorkout else { return }
        
        guard let baseExercise = baseExerciseRepo.fetch(by: exerciseID) else {
            print("Error: ID not found")
            return
        }
        
        let currentCount = currentWorkout.workoutExercises?.count ?? 0
        
        let newWorkoutExercise = exerciseRepo.create()
        newWorkoutExercise.id = UUID()
        newWorkoutExercise.exercise = baseExercise
        newWorkoutExercise.workout = currentWorkout
        newWorkoutExercise.orderIndex = Int16(currentCount)
        
        let initialSet = workoutSets.create()
        initialSet.id = UUID()
        initialSet.orderIndex = 0
        initialSet.isCompleted = false
        initialSet.weight = 0
        initialSet.reps = 0
        initialSet.workoutExercise = newWorkoutExercise
        
        loadPreviousSetsIfNeeded(for: baseExercise, in: currentWorkout)
        persist("addExercise")
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
        guard let workoutExercise = exerciseRepo.fetch(by: workoutExerciseID),
              let newBaseExercise = baseExerciseRepo.fetch(by: newExerciseID) else { return }
        
        workoutExercise.exercise = newBaseExercise
        
        if let currentWorkout {
            loadPreviousSetsIfNeeded(for: newBaseExercise, in: currentWorkout)
        }
        persist("replaceExercise")
    }
      
    
    func updateExerciseNote(workoutExerciseID: String, note: String) {
        guard let exercise = exerciseRepo.fetch(by: workoutExerciseID) else { return }
        exercise.note = note
        persist("updateExerciseNote")
    }
    
    //MARK: - Sets
    func addNewSet(to workoutExerciseID: String) {
        guard let currentExercise = exerciseRepo.fetch(by: workoutExerciseID) else { return }
        
        let currentSetsCount = currentExercise.workoutSets?.count ?? 0
        
        let newSet = workoutSets.create()
        newSet.id = UUID()
        newSet.isCompleted = false
        newSet.weight = 0
        newSet.reps = 0
        newSet.workoutExercise = currentExercise
        newSet.orderIndex = Int16(currentSetsCount)
        
        persist("addNewSet")
    }
    
 
    
    func updateSet(setID: String, weight: Double, reps: Int, isDone: Bool) {
        guard let setToUpdate = workoutSets.fetch(by: setID) else { return }
        
        setToUpdate.weight = weight
        setToUpdate.reps = Int16(reps)
        setToUpdate.isCompleted = isDone
        
        persist("updateSet")
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
    
    //MARK: - Helpers
    private func persist(_ label: String) {
        workoutRepo.save()
            .sink { completion in
                if case .failure(let error) = completion {
                    print("\(label) failed: \(error)")
                }
            } receiveValue: { [weak self] _ in
                self?.notifyUI()
            }
            .store(in: &cancellables)
    }
    
    private func loadPreviousSetsIfNeeded(for baseExercise: Exercise, in workout: Workout) {
        guard let key = baseExercise.id?.uuidString, cachedPreviousSets[key] == nil else { return }
        
        let pastSession = exerciseRepo.fetchPreviousSession(for: baseExercise, currentWorkout: workout)
        
        let pastSets = (pastSession?.workoutSets as? Set<WorkoutSet> ?? [])
            .sorted { $0.orderIndex < $1.orderIndex }
            .map { cdSet in
                WorkoutSetDomainModel(
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

        cachedPreviousSets[key] = pastSets
    }
    
    //MARK: - NotifyUI
    private func notifyUI() {
        guard let workout = currentWorkout, !workout.isDeleted else { return }
        
        let result = WorkoutSessionMapper.map(workout, previousSets: cachedPreviousSets)
        exercisesSubject.send(result.exercises)
        sessionStatsSubject.send((volume: result.volume, sets: result.completedSets))
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
