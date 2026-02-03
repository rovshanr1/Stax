//
//  DataRepository.swift
//  Stax
//
//  Created by Rovshan Rasulov on 11.12.25.
//

import Foundation
import Combine
import CoreData

final class DataRepository<T: NSManagedObject>: GenericRepository{
    //Generic type
    typealias Entity = T
    
    //Properties
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetch(predicate: NSPredicate? = nil, sortDescirptors: [NSSortDescriptor]? = nil, fetchLimit: Int? = nil) -> [T]{
        guard let entityName = T.entity().name else { return []}
        
        let request = NSFetchRequest<T>(entityName: entityName)
        request.predicate = predicate
        request.sortDescriptors = sortDescirptors
        
        if let limit = fetchLimit{
            request.fetchLimit = limit
        }
        
        do {
            return try context.fetch(request)
        }catch{
            print("❌ Repository Fetch Error: \(error)")
            return []
        }
    }
    
    func fetchAll() -> AnyPublisher<[T], Error> {
        let request = T.fetchRequest()
        
        return Future {promise in
            self.context.perform {
                do{
                    let result = try self.context.fetch(request) as! [T]
                    promise(.success(result))
                }catch{
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func search(by predicate: NSPredicate?) -> AnyPublisher<[T], Error> {
        let request = T.fetchRequest()
        request.predicate = predicate
        
        return Future {promise in
            self.context.perform {
                do{
                    let result = try self.context.fetch(request) as! [T]
                    promise(.success(result))
                }catch{
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func create() -> T {
        let entityName = T.entity()
        
        let object = NSEntityDescription.insertNewObject(forEntityName: entityName.name!, into: context) as! T
        return object
    }
    
    func delete(_ entity: T) -> AnyPublisher<Void,  Error> {
        return Future { promise in
            self.context.perform {
                self.context.delete(entity)
                return promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }
    
    
    
    func save() -> AnyPublisher<Void, Error> {
        return Future { promise in
            self.context.perform{
                do{
                    try self.context.save()
                    promise(.success(()))
                }catch{
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func makeFetchResultsController(sortDescriptors: [NSSortDescriptor], predicate: NSPredicate? = nil) -> NSFetchedResultsController<T>{
        let request = NSFetchRequest<T>(entityName: T.entity().name!)
        request.sortDescriptors = sortDescriptors
        request.predicate = predicate
        
        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
    
    
    func update(id: NSManagedObjectID, configure: @escaping (T) -> Void) -> AnyPublisher<Void, Error> {
        return Future { promise in
            self.context.perform {
                do{
                    let object = try self.context.existingObject(with: id) as! T
                    
                    configure(object)
                    
                    if self.context.hasChanges {
                        try self.context.save()
                    }
                    
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}


extension DataRepository where T == WorkoutExercise {
    func fetchPreviousSession(for exerciseDef: Exercise, currentWorkout: Workout) -> WorkoutExercise? {
        let request: NSFetchRequest<WorkoutExercise> = WorkoutExercise.fetchRequest()
        
        let cutoffDate: Date = currentWorkout.date ?? Date()
        request.predicate = NSPredicate(
            format: "exercise == %@ AND workout != %@ AND workout.date < %@",
            argumentArray: [exerciseDef, currentWorkout, cutoffDate as NSDate]
        )
        
        request.sortDescriptors = [NSSortDescriptor(key: "workout.date", ascending: false)]
        
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            return results.first
        }catch{
            print("Error fetching previous session for exercise: \(exerciseDef.name ?? "Unknown Exercise")")
            return nil
        }
    }
}

