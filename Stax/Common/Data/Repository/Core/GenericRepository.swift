//
//  GenericRepository.swift
//  Stax
//
//  Created by Rovshan Rasulov on 11.12.25.
//

import Foundation
import Combine
import CoreData

protocol GenericRepository{
    associatedtype Entity: NSManagedObject
    
    func fetchAll() -> AnyPublisher<[Entity], Error>
    func search(by predicate: NSPredicate?) -> AnyPublisher<[Entity], Error>
    func create() -> Entity
    func save() -> AnyPublisher<Void, Error>
    func delete(_ entity: Entity) -> AnyPublisher<Void, Error>
}
