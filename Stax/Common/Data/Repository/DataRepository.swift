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
}
