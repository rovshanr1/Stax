//
//  UserDataWipeService.swift
//  Stax
//
//  Created by Rovshan Rasulov on 03.06.26.
//

import Foundation
import CoreData


protocol UserDataWipeServiceProtocol{
    func wipeAllLocalData() async throws
}

final class UserDataWipeService: UserDataWipeServiceProtocol {
    private let userDefaults: UserDefaults
    private let fileManager: FileManager
    private let persistentStoreCoordinator: NSPersistentStoreCoordinator
    
    init(userDefaults: UserDefaults,
         fileManager: FileManager,
         persistentStoreCoordinator: NSPersistentStoreCoordinator
    ) {
        self.userDefaults = userDefaults
        self.fileManager = fileManager
        self.persistentStoreCoordinator = persistentStoreCoordinator
    }
    
    
    func wipeAllLocalData() async throws {
        try await Task(priority: .background) {
            self.wipeUserDefaults()
            try self.wipeCoreDataFiles()
        }.value
    }
    
    
    
    private func wipeUserDefaults() {
        guard let domain = Bundle.main.bundleIdentifier else { return }
        
        userDefaults.removePersistentDomain(forName: domain)
    }
    
    private func wipeCoreDataFiles() throws{
        guard let appSupportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "WipeService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Application Support directory not found."])
        }
        
        let storeName = "Stax"
        let storeURL = appSupportDirectory.appendingPathComponent("\(storeName).sqlite")
        
        try persistentStoreCoordinator.destroyPersistentStore(
            at: storeURL,
            type: .sqlite
        )
    }
    
}
