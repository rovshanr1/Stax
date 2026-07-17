//
//  PersistenceController.swift
//  Stax
//
//  Created by Rovshan Rasulov on 04.06.26.
//

import Foundation
import CoreData

protocol PersistenceControllerProtocol {
    var viewContext: NSManagedObjectContext { get }
    func performBackgroundTask(_ task: @escaping (NSManagedObjectContext) -> Void)
    func resetStack() throws
    func saveContext()
}

final class PersistenceController: PersistenceControllerProtocol {
    
    private let modelName: String
    private var container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    static let sharedModel: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Stax", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: url) else{
            fatalError("Could not load model")
        }
        
        return model
    }()
    
    init(modelName: String = "Stax") {
        self.modelName = modelName
        
        self.container = NSPersistentContainer(name: modelName, managedObjectModel: Self.sharedModel)
        self.container.loadPersistentStores { _, error in
            if let error = error { fatalError("Core Data did not load: \(error)") }
        }
    }
    
    func performBackgroundTask(_ task: @escaping (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask(task)
    }
    
    func resetStack() throws {
        guard let firstStore = container.persistentStoreDescriptions.first,
        let storeURL = firstStore.url else{ return }
        
        let coordinator = container.persistentStoreCoordinator
        
        try coordinator.destroyPersistentStore(at: storeURL, type: .sqlite)
        
        self.container = NSPersistentContainer(name: modelName, managedObjectModel: Self.sharedModel)
        self.container.loadPersistentStores { _, error in
            if let error = error { print("Reload error: \(error)") }
        }
    }
    
    func saveContext(){
        let context = container.viewContext
        
        guard context.hasChanges else { return }
        
        do{
            try context.save()
        }catch{
            let nsError = error as NSError
            print("Core Data save error: \(nsError), \(nsError.userInfo)")
        }
    }
}
