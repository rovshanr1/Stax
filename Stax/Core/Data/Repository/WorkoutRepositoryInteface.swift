//
//  WorkoutRepositoryInteface.swift
//  Stax
//
//  Created by Rovshan Rasulov on 21.03.26.
//

import Foundation
import CoreData
import Combine

enum WorkoutFinalizationError: Error {
    case workoutNotFound
}

protocol WorkoutRepositoryProtocol{
    var workoutPublisher: CurrentValueSubject<[WorkoutDomainModel]?, Never> { get }
    func fetchWorkouts()
    func deleteWorkout(by id: String)
    func getWorkout(by id: String) -> WorkoutDomainModel?
    
    func fetchWorkoutDetails(by id: String) -> WorkoutDomainModel?
    func finalizeWorkout(id: String, title: String, description: String, stats: WorkoutStats) async throws -> WorkoutDomainModel
    
}

final class WorkoutRepository: NSObject, WorkoutRepositoryProtocol {
    
    
    var workoutPublisher = CurrentValueSubject<[WorkoutDomainModel]?, Never>(nil)
    
    private let genericRepository: DataRepository<Workout>
    private var frc: NSFetchedResultsController<Workout>?
    private var cancellables: Set<AnyCancellable> = []
    
    init(genericRepository: DataRepository<Workout>) {
        self.genericRepository = genericRepository
        super.init()
        setupFRC()
    }
    
    private func setupFRC() {
        let sort = NSSortDescriptor(key: "date", ascending: false)
        let predicate = NSPredicate(format: "duration > 0")
        
        frc = genericRepository.makeFetchResultsController(sortDescriptors: [sort], predicate: predicate)
        frc?.delegate = self
    }
    
    func fetchWorkouts() {
        try? frc?.performFetch()
        sendCurrentWorkoutToPublisher()
    }
    
    func deleteWorkout(by id: String) {
        genericRepository.delete(by: id)
            .sink(receiveCompletion: {_ in }, receiveValue: {_ in})
            .store(in: &cancellables)
    }
    
    func getWorkout(by id: String) -> WorkoutDomainModel? {
        guard let workout = frc?.fetchedObjects?.first(where: { $0.id?.uuidString == id}) else {return nil}
        return workout.toDomain()
    }
    
    private func sendCurrentWorkoutToPublisher() {
        guard let workouts = frc?.fetchedObjects else {return}
        
        let domainModels = workouts.map { $0.toDomain() }
        workoutPublisher.send(domainModels)
    }
    
    func fetchWorkoutDetails(by id: String) -> WorkoutDomainModel? {
        genericRepository.fetch(by: id)?.toDomain()
    }
    
    func finalizeWorkout(id: String, title: String, description: String, stats: WorkoutStats) async throws -> WorkoutDomainModel {
        guard let workout = genericRepository.fetch(by: id) else {
            throw WorkoutFinalizationError.workoutNotFound
        }
        
        if !title.isEmpty {
            workout.name = title
        }
        workout.workoutDescription = description
        
        if let calories = stats.caloriesBurned {
            workout.calories = Int16(calories)
        }
        workout.sets = Int16(stats.totalSets)
        workout.volume = stats.volume
        workout.duration = stats.duration
        
        try await genericRepository.saveAsync()
        
        return workout.toDomain()
    }
}

extension WorkoutRepository: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        sendCurrentWorkoutToPublisher()
    }
}
