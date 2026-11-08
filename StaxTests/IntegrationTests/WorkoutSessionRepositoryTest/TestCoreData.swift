//
//  TestCoreData.swift
//  StaxTests
//
//  Created by Rovshan Rasulov on 08.11.26.
//

import CoreData
@testable import Stax

enum TestCoreData{
    static let modelName = "Stax"
    
    private static let model: NSManagedObjectModel = {
        let bundle = Bundle(for: WorkoutSessionRepository.self)
        guard let url = bundle.url(forResource: modelName, withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Core Data model '\(modelName)' not found")
        }
        return model
    }()
    
    
    static func makeContext() -> NSManagedObjectContext {
        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            if let error { fatalError("Test store dont loaded: \(error)") }
        }
        return container.viewContext
    }
}
