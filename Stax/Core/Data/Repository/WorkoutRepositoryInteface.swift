//
//  WorkoutRepositoryInteface.swift
//  Stax
//
//  Created by Rovshan Rasulov on 21.03.26.
//

import Foundation
import CoreData
import Combine

protocol WorkoutRepositoryInterface{
    var workoutPublisher: CurrentValueSubject<[WorkoutDomainModel], Never> { get }
    func fetchWorkouts()
    func deleteWorkout(by id: String)
    func getWorkout(by id: String) -> WorkoutDomainModel?
}

final class WorkoutRepository: NSObject, WorkoutRepositoryInterface {
   
    
    var workoutPublisher = CurrentValueSubject<[WorkoutDomainModel], Never>([])
    
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
}

extension WorkoutRepository: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        sendCurrentWorkoutToPublisher()
    }
}
